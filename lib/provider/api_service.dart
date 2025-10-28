import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/env_config.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';

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

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? data,
    bool autoLogoutOnAuthFailure = true,
  }) async {
    final AuthService authService = AuthService();
    String? token = await authService.getValidAccessToken();

    // Debug: print token fingerprint so we can tell which token is used
    String? tokenOwner;
    try {
      if (token != null) {
        final prefix = token.substring(0, min(10, token.length));
        debugPrint('🔐 ApiService.post using token prefix: $prefix');

        // Try to decode token to see which user it belongs to (for debugging)
        try {
          final decodedPayload = _decodeTokenPayload(token);
          if (decodedPayload != null) {
            debugPrint(
                '🔐 ApiService.post decoded token payload: $decodedPayload');
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
        } catch (e) {
          debugPrint('🔐 Could not decode token payload: $e');
        }
      } else {
        debugPrint('🔐 ApiService.post no token available');
      }
    } catch (_) {}

    if (token == null) {
      print('❌ No valid token available for API call - session expired');
      throw AuthenticationException('Session expired');
    }

    // Inject impersonation header if an impersonated email is set
    final extraHeaders = <String, String>{};
    final g = GlobalDataManager();
    // If a client-side owner override is present, use it for display/logging
    // so diagnostic logs match what QA expects to see when using view-only mode.
    if (g.impersonationOwnerOverride != null &&
        g.impersonationOwnerOverride!.isNotEmpty) {
      tokenOwner = g.impersonationOwnerOverride;
      debugPrint(
          '🔐 ApiService.post using owner override for logs: $tokenOwner');
    }
    if (g.impersonatedEmail != null && g.impersonatedEmail!.isNotEmpty) {
      extraHeaders['X-Impersonate-Email'] = g.impersonatedEmail!;
      debugPrint(
        '🔐 ApiService.post adding impersonation header: ${g.impersonatedEmail}',
      );
    }

    // If caller didn't supply data, and impersonation is active, send the
    // impersonated email as the request body so backend endpoints that
    // default to current user will use the impersonated account.
    dynamic sendData = data;
    if ((data == null || data.isEmpty) &&
        g.impersonatedEmail != null &&
        g.impersonatedEmail!.isNotEmpty) {
      sendData = {'email': g.impersonatedEmail};
    }

    // Log outgoing request (mask auth token) when impersonation active to
    // help debugging why backend returns admin data.
    try {
      // final logHeaders = Map<String, String>.from({
      //   ...{
      //     ...extraHeaders,
      //   }
      // });
      // if (logHeaders.containsKey('Authorization')) {
      //   logHeaders['Authorization'] = 'Bearer <masked>'; // never log full token
      // }
      debugPrint('➡️ ApiService.post -> $baseUrl$url');
      debugPrint('   🔑 Token owner: ${tokenOwner ?? "unknown"}');
      // debugPrint('   📤 Headers (masked): $logHeaders');
      debugPrint('   📋 Body: ${json.encode(sendData ?? {})}');
    } catch (_) {}

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...extraHeaders,
      },
      body: json.encode(sendData ?? {}), // always send at least {}
    );

    // Check for authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('❌ API authentication failed - server rejected token');
      if (autoLogoutOnAuthFailure) {
        // Clear tokens and trigger session expiry handling
        await authService.handleServerAuthenticationFailure();
        throw AuthenticationException('Authentication failed');
      } else {
        // Return a structured response so callers can handle it gracefully
        if (response.body.isEmpty)
          return {'statusCode': response.statusCode, 'body': null};
        try {
          return {
            'statusCode': response.statusCode,
            'body': json.decode(response.body),
          };
        } catch (e) {
          return {'statusCode': response.statusCode, 'body': response.body};
        }
      }
    }

    if (response.body.isEmpty) return null;
    // debugPrint("➡️ FULL URL: $baseUrl$url");
    // debugPrint("➡️ POST BYTES URL: $baseUrl$url");
    try {
      return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ JSON decode error: $e");
      // Fallback: return raw string when response is not JSON
      return response.body;
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
    // Add impersonation header if present
    final extraHeadersBytes = <String, String>{};
    final gBytes = GlobalDataManager();
    if (gBytes.impersonationOwnerOverride != null &&
        gBytes.impersonationOwnerOverride!.isNotEmpty) {
      tokenOwner = gBytes.impersonationOwnerOverride;
      debugPrint(
          '🔐 ApiService.postWithBytes using owner override for logs: $tokenOwner');
    }
    if (gBytes.impersonatedEmail != null &&
        gBytes.impersonatedEmail!.isNotEmpty) {
      extraHeadersBytes['X-Impersonate-Email'] = gBytes.impersonatedEmail!;
      debugPrint(
        '🔐 ApiService.postWithBytes adding impersonation header: ${gBytes.impersonatedEmail}',
      );
    }

    // If no data provided, attach impersonatedEmail as body so endpoints
    // that expect the user's email will receive the impersonated one.
    dynamic sendBytesData = data;
    if ((data == null || data.isEmpty) &&
        gBytes.impersonatedEmail != null &&
        gBytes.impersonatedEmail!.isNotEmpty) {
      sendBytesData = {'email': gBytes.impersonatedEmail};
    }

    try {
      final logHeaders = Map<String, String>.from({
        ...{
          ...extraHeadersBytes,
        }
      });
      if (logHeaders.containsKey('Authorization')) {
        logHeaders['Authorization'] = 'Bearer <masked>';
      }
      debugPrint('➡️ ApiService.postWithBytes -> $baseUrl$url');
      debugPrint('   Headers (masked): $logHeaders');
      debugPrint('   Body: ${json.encode(sendBytesData ?? {})}');
    } catch (_) {}

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...extraHeadersBytes,
      },
      body: json.encode(sendBytesData),
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
        final prefix = token.substring(0, min(10, token.length));
        debugPrint('🔐 ApiService.postJson using token prefix: $prefix');
        final decodedPayload = _decodeTokenPayload(token);
        if (decodedPayload != null) {
          debugPrint(
              '🔐 ApiService.postJson decoded token payload: $decodedPayload');
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

    // Add impersonation header if set in GlobalDataManager
    final extra = <String, String>{};
    final gg = GlobalDataManager();
    if (gg.impersonationOwnerOverride != null &&
        gg.impersonationOwnerOverride!.isNotEmpty) {
      tokenOwner = gg.impersonationOwnerOverride;
      debugPrint(
          '🔐 ApiService.postJson using owner override for logs: $tokenOwner');
    }
    if (gg.impersonatedEmail != null && gg.impersonatedEmail!.isNotEmpty) {
      extra['X-Impersonate-Email'] = gg.impersonatedEmail!;
      debugPrint(
        '🔐 ApiService.postJson adding impersonation header: ${gg.impersonatedEmail}',
      );
    }

    // Default empty POST bodies to include impersonated email when active
    dynamic sendJson = data;
    if ((data == null || data.isEmpty) &&
        gg.impersonatedEmail != null &&
        gg.impersonatedEmail!.isNotEmpty) {
      sendJson = {'email': gg.impersonatedEmail};
    }

    try {
      final logHeaders = Map<String, String>.from({
        ...{
          ...extra,
        }
      });
      if (logHeaders.containsKey('Authorization')) {
        logHeaders['Authorization'] = 'Bearer <masked>';
      }
      debugPrint('➡️ ApiService.postJson -> $baseUrl$url');
      debugPrint('   🔑 Token owner: ${tokenOwner ?? "unknown"}');
      debugPrint('   📤 Headers (masked): $logHeaders');
      debugPrint('   📋 Body: ${json.encode(sendJson ?? {})}');
    } catch (_) {}

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...extra,
      },
      body: json.encode(sendJson ?? {}),
    );

    // Check for authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('❌ API authentication failed - server rejected token');
      // Clear tokens and trigger session expiry handling
      await authService.handleServerAuthenticationFailure();
      throw AuthenticationException('Authentication failed');
    }

    // debugPrint("➡️ FULL URL: $baseUrl$url");
    // debugPrint("➡️ POST JSON URL: $baseUrl$url");
    // debugPrint("📤 Request body: ${json.encode(data ?? {})}");
    // debugPrint("📥 Response status: ${response.statusCode}");
    // debugPrint("📥 Response body: ${response.body}");

    if (response.body.isEmpty) return null;

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

      final extraGet = <String, String>{};
      final gget = GlobalDataManager();
      if (gget.impersonatedEmail != null &&
          gget.impersonatedEmail!.isNotEmpty) {
        extraGet['X-Impersonate-Email'] = gget.impersonatedEmail!;
        debugPrint(
          '🔐 ApiService.get adding impersonation header: ${gget.impersonatedEmail}',
        );
      }

      // Log the complete request
      try {
        final logHeaders = Map<String, String>.from({
          ...extraGet,
          ...?headers,
        });
        if (logHeaders.containsKey('Authorization')) {
          logHeaders['Authorization'] = 'Bearer <masked>';
        }
        debugPrint('➡️ ApiService.get -> $url');
        debugPrint('   🔑 Token owner: ${tokenOwner ?? "unknown"}');
        debugPrint('   📤 Headers (masked): $logHeaders');
      } catch (_) {}

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add this
          'Content-Type': 'application/json',
          ...extraGet,
          ...?headers,
        },
      );

      // debugPrint("🔍 GET Request URL: $url");
      // debugPrint("🔍 GET Response Status: ${response.statusCode}");
      // debugPrint("🔍 GET Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ API authentication failed - server rejected token');
        // Clear tokens and trigger session expiry handling
        await authService.handleServerAuthenticationFailure();
        throw AuthenticationException('Authentication failed');
      } else {
        throw Exception(
          'GET request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // debugPrint('❌ GET request error: $e');
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
