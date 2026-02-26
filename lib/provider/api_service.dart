import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/env_config.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

import 'package:flutter/foundation.dart';

// Custom exception for authentication failures
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class ApiService {
  final String baseUrl = EnvConfig.apiBaseUrl;
  String? tokenOwner;

  // Add cookie support for session management
  static final Dio _dio = Dio();
  static final CookieJar _cookieJar = CookieJar();
  static bool _initialized = false;

  ApiService() {
    if (!_initialized) {
      if (!kIsWeb) {
        // Only use CookieManager on Mobile/Desktop (Native).
        // On Web, the Browser handles cookies automatically.
        _dio.interceptors.add(CookieManager(_cookieJar));
      } else {
        // Switch-user on web relies on server session cookies.
        // Ensure browser sends/receives cookies for cross-origin API calls.
        try {
          _dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
          debugPrint('🌐 ApiService web credentials explicitly enabled');
        } catch (e) {
          debugPrint('⚠️ ApiService error setting web credentials: $e');
        }
      }
      _initialized = true;
    }
  }

  static void clearCookies() {
    _cookieJar.deleteAll();
  }

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? data,
    bool autoLogoutOnAuthFailure = true,
  }) async {
    final AuthService authService = AuthService();
    String? token = await authService.getValidAccessToken();

    if (token == null) {
      print('❌ No valid token available for API call - session expired');
      throw AuthenticationException('Session expired');
    }

    dynamic sendData = data;

    try {
      final response = await _dio.post(
        '$baseUrl$url',
        data: sendData ?? {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain,
          extra: kIsWeb ? {'withCredentials': true} : null,
        ),
      );

      // debugPrint("🔧 Raw response body: ${response.data}");

      // Try to parse as JSON
      try {
        final jsonResponse = json.decode(response.data.toString());

        // ✅ Check if response contains a new token (for switch user scenarios)
        if (jsonResponse is Map<String, dynamic>) {
          final newToken = jsonResponse['token'] ??
              jsonResponse['access_token'] ??
              jsonResponse['accessToken'];

          if (newToken != null && newToken.toString().isNotEmpty) {
            final newRefreshToken =
                jsonResponse['refresh_token'] ?? jsonResponse['refreshToken'];

            debugPrint('🔑 Found new token in API response, updating...');
            await authService.updateTokens(
              accessToken: newToken.toString(),
              refreshToken: newRefreshToken?.toString(),
            );
          }
        }

        return jsonResponse;
      } catch (e) {
        // ✅ Try to extract token from string response
        final responseStr = response.data.toString();
        final trimmed = responseStr.trimLeft();
        if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
          debugPrint("❌ JSON decode error: $e");
        } else {
          debugPrint("ℹ️ Non-JSON response body received");
        }
        final tokenRegex =
            RegExp(r'eyJ[A-Za-z0-9_.-]+\.[A-Za-z0-9_.-]+\.[A-Za-z0-9_.-]*');
        final tokenMatch = tokenRegex.firstMatch(responseStr);

        if (tokenMatch != null) {
          final newToken = tokenMatch.group(0);
          debugPrint('🔑 Extracted token from string response, updating...');
          await authService.updateTokens(accessToken: newToken!);
        }

        return response.data.toString();
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          debugPrint("🛑 401 Unauthorized in post - logging out");
          await _handleAuthError();
          throw AuthenticationException('Unauthorized');
        }

        debugPrint("❌ Dio error: ${e.message}");
        if (e.response != null) {
          debugPrint("🔧 Error response body: ${e.response?.data}");
          return e.response?.data?.toString() ?? 'Network error';
        }
      }
      rethrow;
    }
  }

  Future<dynamic> postWithBytes(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    final AuthService authService = AuthService();
    bool isTokenValid = await authService.checkToken();
    if (!isTokenValid) {
      throw Exception('Authentication required');
    }
    String? token = await authService.getAccessToken();
    try {
      if (token != null) {
        final prefix = token.substring(0, min(10, token.length));
        debugPrint('🔐 ApiService.postWithBytes using token prefix: $prefix');
        try {
          final parts = token.split('.');
          if (parts.length >= 2) {
            // Use base64Url.normalize to handle padding correctly
            final normalized = base64Url.normalize(parts[1]);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final payload = json.decode(decoded);
            tokenOwner =
                payload['email'] ?? payload['preferred_username'] ?? 'unknown';
            debugPrint('🔐 Token belongs to: $tokenOwner');
          }
        } catch (e) {
          debugPrint('🔐 Could not decode token payload: $e');
        }
      }
    } catch (_) {}

    dynamic sendBytesData = data;

    // Use Dio for binary data to ensure correct handling on Web
    try {
      final response = await _dio.post(
        '$baseUrl$url',
        data: sendBytesData ?? {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes, // Important for PDF
          extra: kIsWeb ? {'withCredentials': true} : null,
        ),
      );

      // Dio throws on 4xx/5xx by default, so if we are here, it's 2xx.
      // But we should check content-type just in case.

      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';

      if (contentType.contains('application/json') ||
          contentType.contains('text/')) {
        // It returned text/json instead of bytes -> probably an error message
        // Dio with ResponseType.bytes stores body in response.data as List<int>
        // We need to decode it to see the error
        try {
          final textData = utf8.decode(response.data);
          debugPrint(
              "⚠️ postWithBytes received Text/JSON instead of PDF: $textData");
          return textData; // Return the error string
        } catch (e) {
          return 'Error decoding response';
        }
      }

      // Check for specific error string if it somehow came as bytes
      // (Unlikely if we checked content-type, but safe to keep logic)
      try {
        // Converting huge PDF to string is expensive, so maybe skip this check
        // unless we are unsure.
        // But the original code checked for "Incorrect result size".
        // Let's assume if it's PDF content-type, it's good.
      } catch (_) {}

      // response.data is List<int> (Uint8List compatible)
      return Uint8List.fromList(response.data);
    } catch (e) {
      if (e is DioError) {
        debugPrint("❌ postWithBytes Dio error: ${e.message}");
        if (e.response != null) {
          // Try to read error body
          try {
            // If responseType was bytes, data is bytes.
            final errText = utf8.decode(e.response!.data);
            debugPrint("🔧 Error response body: $errText");
            return errText;
          } catch (_) {
            return e.message;
          }
        }
      }
      rethrow;
    }
  }

  Future<dynamic> postJson(String url, {Map<String, dynamic>? data}) async {
    final AuthService authService = AuthService();
    String? token = await authService.getValidAccessToken();
    String? tokenOwner;
    try {
      if (token != null) {
        // debugPrint('🔐 ApiService.postJson using token prefix: ${token.substring(0, min(10, token.length))}');
        final decodedPayload = _decodeTokenPayload(token);
        if (decodedPayload != null) {
          // debugPrint(
          //     '🔐 ApiService.postJson decoded token payload: $decodedPayload');
          try {
            final Map<String, dynamic> payloadJson =
                Map<String, dynamic>.from(json.decode(decodedPayload));
            tokenOwner = payloadJson['email'] ??
                payloadJson['preferred_username'] ??
                payloadJson['sub'] ??
                payloadJson['userId'] ??
                'unknown';
            debugPrint('🔐 Token belongs to: $tokenOwner');
          } catch (e) {
            debugPrint('🔐 Could not parse decoded token payload JSON: $e');
          }
        }
      }
    } catch (_) {}
    if (token == null) {
      print('❌ No valid token available for API call - session expired');
      throw AuthenticationException('Session expired');
    }

    // debugPrint("➡️ FULL URL: $baseUrl$url");
    // debugPrint("📤 Request body: ${json.encode(data ?? {})}");
    // debugPrint("Posting to full URL: $baseUrl$url");

    dynamic sendJson = data;

    try {
      final response = await _dio.post(
        '$baseUrl$url',
        data: sendJson ?? {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          extra: kIsWeb ? {'withCredentials': true} : null,
        ),
      );

      // Handle cases where the server returns a 200/500 but with HTML instead of JSON
      if (response.data is String &&
          ((response.data as String).trim().startsWith('<!DOCTYPE') ||
              (response.data as String).trim().startsWith('<html') ||
              (response.data as String).trim().startsWith('Cannot inv'))) {
        debugPrint(
            "❌ postJson: Received non-JSON error response from $url (starts with '${(response.data as String).substring(0, 10)}')");
        return null;
      }

      return response.data; // Dio decodes JSON automatically
    } on DioException catch (e) {
      debugPrint("❌ postJson Dio error: $e");
      if (e.response?.data != null) {
        debugPrint("❌ postJson Error data: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      debugPrint("❌ postJson Unexpected error: $e");
      return null;
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      // Add authentication
      final AuthService authService = AuthService();
      String? token = await authService.getValidAccessToken();
      String? tokenOwner;
      try {
        if (token != null) {
          final prefix = token.substring(0, min(10, token.length));
          debugPrint('🔐 ApiService.get using token prefix: $prefix');

          // Decode token payload safely (base64url normalization).
          final decodedPayload = _decodeTokenPayload(token);
          if (decodedPayload != null) {
            try {
              final payload = json.decode(decodedPayload);
              tokenOwner = payload['email'] ??
                  payload['preferred_username'] ??
                  payload['sub'] ??
                  'unknown';
              debugPrint('🔐 Token belongs to: $tokenOwner');
            } catch (e) {
              debugPrint('🔐 Could not parse decoded token payload JSON: $e');
            }
          }
        }
      } catch (_) {}
      if (token == null) {
        print('❌ No valid token available for API call - session expired');
        throw AuthenticationException('Session expired');
      }

      final response = await _dio.get(
        '$baseUrl$endpoint',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            ...?headers,
          },
          responseType: ResponseType.plain,
          extra: kIsWeb ? {'withCredentials': true} : null,
        ),
      );

      final body = response.data?.toString() ?? '';
      try {
        return json.decode(body);
      } catch (_) {
        // Return raw response for non-JSON endpoints/cases.
        return body;
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          debugPrint('🛑 401 Unauthorized in get - logging out');
          await _handleAuthError();
          throw AuthenticationException('Unauthorized');
        }
      }
      rethrow;
    }
  }

  Future<void> _handleAuthError() async {
    final AuthService authService = AuthService();
    await authService.handleServerAuthenticationFailure();
  }

  // Find where you're decoding the token (likely in ApiService)
  String? _decodeTokenPayload(String token) {
    try {
      // Split JWT into parts
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint(
            '⚠️ Invalid JWT format: expected 3 parts, got ${parts.length}');
        return null;
      }

      // Get the payload (middle part)
      String payload = parts[1];

      // ✅ FIX: Normalize Base64 padding
      // Base64 strings should be padded to a multiple of 4 characters
      switch (payload.length % 4) {
        case 0:
          break; // No padding needed
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          debugPrint('⚠️ Invalid Base64 length');
          return null;
      }

      // ✅ FIX: Replace Base64URL characters with standard Base64
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      // Decode Base64
      final decoded = utf8.decode(base64.decode(payload));
      return decoded;
    } catch (e) {
      debugPrint('🔐 Could not decode token payload: $e');
      return null;
    }
  }
}
