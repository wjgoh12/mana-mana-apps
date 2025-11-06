import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/env_config.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';

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
      _dio.interceptors.add(CookieManager(_cookieJar));
      _initialized = true;
    }
  }

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? data,
    bool autoLogoutOnAuthFailure = true,
  }) async {
    final AuthService authService = AuthService();
    String? token = await authService.getValidAccessToken();

    // Debug: print token fingerprint so we can tell which token is used
    try {
      if (token != null) {
        // debugPrint('🔐 ApiService.post using token prefix: ${token.substring(0, min(10, token.length))}');

        // Try to decode token to see which user it belongs to (for debugging)
        try {
          final decodedPayload = _decodeTokenPayload(token);
          if (decodedPayload != null) {
            // debugPrint('🔐 ApiService.post decoded token payload: $decodedPayload');
            // Token parsing for debugging is available but commented out to avoid lint warnings
          }
        } catch (e) {
          debugPrint('🔐 Could not decode token payload: $e');
        }
      } else {
        // debugPrint('🔐 ApiService.post no token available');
      }
    } catch (_) {}

    if (token == null) {
      print('❌ No valid token available for API call - session expired');
      throw AuthenticationException('Session expired');
    }

    dynamic sendData = data;

    try {
      // Use Dio for cookie support (maintains sessions)
      final response = await _dio.post(
        '$baseUrl$url',
        data: sendData ?? {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain, // Get response as string to handle malformed JSON
        ),
      );

      debugPrint("🔧 Raw response body: ${response.data}");
      
      // Try to parse as JSON first
      try {
        return json.decode(response.data.toString());
      } catch (e) {
        debugPrint("❌ JSON decode error: $e");
        // Fallback: return raw string when response is not JSON
        return response.data.toString();
      }
    } catch (e) {
      if (e is DioError) {
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

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(sendBytesData ?? {}),
    );

    if (response.body.toString().contains("Incorrect result size")) {
      return 'Incorrect result size';
    } else {
      return response.bodyBytes;
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

    // try {
    //   final logHeaders = Map<String, String>.from({
    //     ...{
    //       ...extra,
    //     }
    //   });
    //   if (logHeaders.containsKey('Authorization')) {
    //     logHeaders['Authorization'] = 'Bearer <masked>';
    //   }
    //   debugPrint('➡️ ApiService.postJson -> $baseUrl$url');
    //   debugPrint('   🔑 Token owner: ${tokenOwner ?? "unknown"}');
    //   debugPrint('   📤 Headers (masked): $logHeaders');
    //   debugPrint('   📋 Body: ${json.encode(sendJson ?? {})}');
    // } catch (_) {}

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(sendJson ?? {}),
    );

    try {
      return json.decode(response.body);
    } catch (e) {
      // debugPrint("❌ JSON decode error: $e");
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

          // Try to decode token to see which user it belongs to
          try {
            final parts = token.split('.');
            if (parts.length >= 2) {
              final payload = json.decode(utf8.decode(
                  base64Decode(parts[1] + '=' * (4 - parts[1].length % 4))));
              tokenOwner = payload['email'] ??
                  payload['preferred_username'] ??
                  'unknown';
              debugPrint('🔐 Token belongs to: $tokenOwner');
            }
          } catch (e) {
            debugPrint('🔐 Could not decode token payload: $e');
          }
        }
      } catch (_) {}
      if (token == null) {
        print('❌ No valid token available for API call - session expired');
        throw AuthenticationException('Session expired');
      }

      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add this
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      // debugPrint("🔍 GET Request URL: $url");
      // debugPrint("🔍 GET Response Status: ${response.statusCode}");
      // debugPrint("🔍 GET Response Body: ${response.body}");

      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ GET request error: $e');
      rethrow; // Re-throw to preserve the exception type
    }
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
