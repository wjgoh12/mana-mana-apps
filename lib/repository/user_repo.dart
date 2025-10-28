// ============================================
// FILE: user_repo.dart
// ============================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
// AuthService token replacement intentionally not used here; token handling
// is managed elsewhere if needed.

class UserRepository {
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    // If impersonation is active, include the impersonated email in the request
    final g = GlobalDataManager();
    final Map<String, dynamic>? payload =
        (g.impersonatedEmail != null && g.impersonatedEmail!.isNotEmpty)
            ? {'email': g.impersonatedEmail}
            : null;

    return await _apiService
        .post(ApiEndpoint.ownerUserData, data: payload)
        .then((res) {
      try {
        if (res == null) {
          print("⚠️ API returned null for ownerUserData");
          return [];
        }
        debugPrint(
            "✅ API call succeeded for ownerUserData; \nraw response: $res");

        // Support both Map and List responses — prefer first item if List
        Map<String, dynamic> userMap;
        if (res is List && res.isNotEmpty) {
          userMap = Map<String, dynamic>.from(res.first as Map);
        } else if (res is Map<String, dynamic>) {
          userMap = res;
        } else {
          debugPrint(
              '❌ Unexpected response type for ownerUserData: ${res.runtimeType}');
          return [];
        }

        final user = User.fromJson(userMap);

        // Diagnostic: log both userId and email reported by server (if present)
        try {
          final serverUserId = userMap['userId']?.toString();
          final serverEmail = userMap['email']?.toString();
          final token = userMap['token']?.toString();
          debugPrint(
              '🔎 ownerUserData parsed: userId=$serverUserId, email=$serverEmail, token_present=${token != null}');
        } catch (_) {}

        // IMPORTANT: Do NOT synthesize or overwrite server-returned user fields
        // with the client-side requested impersonation email. If the backend
        // does not return the impersonated profile, the client must treat
        // that as the server truth and either fall back to admin or show
        // a clear "view-only" mode. We therefore avoid forcing the email.

        debugPrint("✅ Successfully parsed user: ${user.email}");
        return [user];
      } catch (e) {
        print("❌ Error parsing user data: $e");
        print("❌ Raw response that failed to parse: $res");
        return [];
      }
    });
  }

  /// Validate switch user request before confirming
  Future<Map<String, dynamic>> validateSwitchUser(
      String switchUserEmail) async {
    try {
      final response = await _apiService.post(
        ApiEndpoint.validateUser,
        data: {'switchUserEmail': switchUserEmail},
        // autoLogoutOnAuthFailure: false,
      );

      debugPrint('🔁 validateSwitchUser response: $response');

      // Normalize response to always return Map
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is String) {
        // Convert string response to structured format
        if (response.toLowerCase().contains('not allowed') ||
            response.contains('403')) {
          return {'statusCode': 403, 'body': response, 'success': false};
        }
        return {'statusCode': 200, 'body': response, 'success': true};
      }

      return {
        'statusCode': 500,
        'body': 'Unknown response format',
        'success': false
      };
    } catch (e) {
      debugPrint('❌ validateSwitchUser error: $e');
      return {'statusCode': 500, 'body': e.toString(), 'success': false};
    }
  }

  /// Confirm switch to the provided owner account
  /// Handles both JSON and plain text backend responses
  Future<Map<String, dynamic>> confirmSwitchUser(String switchUserEmail) async {
    try {
      final response = await _apiService.post(ApiEndpoint.confirmUser, data: {
        "switchUserEmail": switchUserEmail, // e.g. hslean1996@hotmail.com
      }

          // autoLogoutOnAuthFailure: false,
          );

      debugPrint('🔁 confirmSwitchUser response: $response');

      // Note: do NOT replace stored tokens here.
      // The backend in this environment does not return replacement tokens
      // for impersonation; token replacement is disabled to avoid swapping
      // the admin token unexpectedly. The switch will be driven by the
      // impersonated email only.

      // ✅ Handle JSON response
      if (response is Map<String, dynamic>) {
        // Try to pull impersonated email if backend included it
        String? impersonatedEmail;
        if (response.containsKey('impersonatedEmail')) {
          impersonatedEmail = response['impersonatedEmail']?.toString();
        } else if (response.containsKey('email')) {
          impersonatedEmail = response['email']?.toString();
        }

        return {
          ...response,
          // 'tokensReplaced': tokensReplaced,
          'impersonatedEmail': impersonatedEmail,
          'success': true,
        };
      }

      // ✅ Handle plain text response (like “Now viewing as: ...”)
      if (response is String) {
        final lower = response.toLowerCase();
        final success = lower.contains('now viewing as') ||
            lower.contains('success') ||
            lower.contains('ok');

        // Attempt to parse an email from the textual response (robust regex)
        String? parsedEmail;
        try {
          final match =
              RegExp(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
                  .firstMatch(response);
          parsedEmail = match?.group(0)?.toLowerCase();
        } catch (_) {
          parsedEmail = null;
        }

        // If the backend only returns a plain-text confirmation but includes
        // the target email, apply a client-side impersonation owner override
        // so the UI and ApiService headers/bodies will use the requested
        // impersonated email. This does NOT replace tokens; it only changes
        // in-memory state and triggers a background fetch via impersonateUser.
        try {
          if (parsedEmail != null && parsedEmail.isNotEmpty) {
            debugPrint(
                '🔁 confirmSwitchUser: applying client-side impersonation for $parsedEmail');
            final g = GlobalDataManager();
            // Use the safer impersonateUser flow which clears caches and
            // fetches the impersonated data in background. Schedule it
            // without awaiting so we return immediately to the caller.
            Future.microtask(() => g.impersonateUser(parsedEmail!));
          }
        } catch (e) {
          debugPrint(
              '⚠️ Failed to apply client-side impersonation override: $e');
        }

        return {
          'statusCode': success ? 200 : 500,
          'body': response,
          'success': success,
          'impersonatedEmail': parsedEmail,
        };
      }

      // ✅ Fallback case
      return {
        'statusCode': 500,
        'body': 'Unknown response format',
        'success': false,
      };
    } catch (e) {
      debugPrint('❌ confirmSwitchUser error: $e');
      return {'statusCode': 500, 'body': e.toString(), 'success': false};
    }
  }

  Future<void> cancelSwitchUser(String email) async {
    final response =
        await _apiService.post(ApiEndpoint.cancelSwitchUser, data: {
      "switchUserEmail": email,
    });
    return response;
  }

  /// Fetch a single user by email. Returns null if not found or error.
  Future<User?> getUserByEmail(String email) async {
    try {
      debugPrint('🔍 getUserByEmail: Fetching user for email: $email');

      // Strategy 1: Try with email parameter in request body
      final possiblePayloads = [
        {'email': email},
        {'switchUserEmail': email},
        {'userEmail': email},
        {'ownerEmail': email},
      ];

      dynamic res;
      for (final payload in possiblePayloads) {
        try {
          debugPrint('🔍 Trying payload: $payload');
          res = await _apiService.post(
            ApiEndpoint.ownerUserData,
            data: payload,
          );

          if (res != null) {
            debugPrint('✅ Got response with payload: $payload');
            break;
          }
        } catch (e) {
          debugPrint('⚠️ Failed with payload $payload: $e');
          res = null;
        }
      }

      // Strategy 2: If no response, try fetching all users and search locally
      if (res == null) {
        debugPrint(
            '🔍 No direct response, fetching all users and searching locally');
        try {
          final allUsers = await getUsers();
          for (final user in allUsers) {
            if ((user.email ?? '').toLowerCase() == email.toLowerCase()) {
              debugPrint('✅ Found user in local list: ${user.email}');
              return user;
            }
          }
          debugPrint('❌ User not found in local list');
          return null;
        } catch (e) {
          debugPrint('❌ Failed to fetch all users: $e');
          return null;
        }
      }

      // Strategy 3: Parse the response
      try {
        // Handle List response
        if (res is List && res.isNotEmpty) {
          debugPrint('📋 Response is a List with ${res.length} items');
          final user = User.fromJson(res.first as Map<String, dynamic>);
          debugPrint('✅ Parsed user from list: ${user.email}');
          return user;
        }

        // Handle Map response
        if (res is Map<String, dynamic>) {
          debugPrint('📦 Response is a Map');
          final user = User.fromJson(res);
          debugPrint('✅ Parsed user from map: ${user.email}');

          // Verify we got the correct user (case-insensitive)
          if ((user.email ?? '').toLowerCase() == email.toLowerCase()) {
            return user;
          } else {
            debugPrint('⚠️ Email mismatch: got ${user.email}, expected $email');
            // Backend might not support email parameter, return anyway
            return user;
          }
        }

        debugPrint('❌ Unexpected response format: ${res.runtimeType}');
        return null;
      } catch (e) {
        debugPrint('❌ Error parsing user response: $e');
        debugPrint('❌ Raw response: $res');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getUserByEmail failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Returns true if user exists, false otherwise
  Future<bool> userExists(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
    } catch (e) {
      debugPrint('❌ userExists check failed: $e');
      return false;
    }
  }

  Future<List<User>> getSwitchedUser(String email) async {
    // Try multiple possible parameter names — some backends expect a different
    // key for the target email. Probe several common keys and log the raw
    // response for each attempt to help backend teams diagnose which payload
    // shape they expect.
    final possiblePayloads = [
      {'email': email},
      {'switchUserEmail': email},
      {'userEmail': email},
      {'ownerEmail': email},
    ];

    debugPrint('🔁 getSwitchedUser: probing payloads for email: $email');

    dynamic res;
    for (final payload in possiblePayloads) {
      try {
        debugPrint('🔁 Trying payload: $payload');
        final attempt = await _apiService.post(
          ApiEndpoint.ownerUserData,
          data: payload,
        );

        debugPrint('🔁 Raw response for payload $payload: $attempt');

        if (attempt != null) {
          res = attempt;
          break;
        }
      } catch (e) {
        debugPrint('⚠️ getSwitchedUser attempt failed for $payload: $e');
        // continue to next payload
      }
    }

    // If we still have no response, try one final time with empty body to let
    // the backend derive target from headers/session.
    if (res == null) {
      try {
        debugPrint('🔁 No payloads succeeded; trying empty body');
        final attempt = await _apiService.post(
          ApiEndpoint.ownerUserData,
        );
        debugPrint('🔁 Raw response for empty payload: $attempt');
        if (attempt != null) {
          res = attempt;
        }
      } catch (e) {
        debugPrint('⚠️ Final empty-body attempt failed: $e');
      }
    }

    try {
      if (res == null) {
        print("⚠️ other user API returned null for ownerUserData");
        return [];
      }
      debugPrint(
          "✅ API call succeeded for switched ownerUserData; raw response: $res");

      // Support both Map and List responses — prefer first item if List
      Map<String, dynamic> userMap;
      if (res is List && res.isNotEmpty) {
        userMap = Map<String, dynamic>.from(res.first as Map);
      } else if (res is Map<String, dynamic>) {
        userMap = res;
      } else {
        debugPrint(
            '❌ Unexpected response type for ownerUserData: ${res.runtimeType}');
        return [];
      }

      final user = User.fromJson(userMap);

      // Log diagnostic info so backend team can see where fields disagree
      try {
        final serverUserId = userMap['userId']?.toString();
        final serverEmail = userMap['email']?.toString();
        final token = userMap['token']?.toString();
        debugPrint(
            '🔎 getSwitchedUser parsed: userId=$serverUserId, email=$serverEmail, token_present=${token != null}');

        // If token present, attempt to decode payload.sub to verify identity
        if (token != null && token.isNotEmpty) {
          try {
            final parts = token.split('.');
            if (parts.length >= 2) {
              final normalized = base64Url.normalize(parts[1]);
              final decoded = utf8.decode(base64Url.decode(normalized));
              debugPrint('🔐 token payload: $decoded');
              try {
                final Map<String, dynamic> payloadJson =
                    Map<String, dynamic>.from(json.decode(decoded));
                debugPrint(
                    '🔐 token.sub: ${payloadJson['sub']}, token.email?: ${payloadJson['email'] ?? ''}');
              } catch (_) {}
            }
          } catch (e) {
            debugPrint('⚠️ Failed to decode token payload: $e');
          }
        }
      } catch (_) {}

      // Do not overwrite server response. If server did not honor impersonation
      // (i.e., userId or other identifier still points to admin), the app must
      // not synthesize a new identity locally.

      debugPrint("Successfully parsed switched user: ${user.ownerEmail}");
      return [user];
    } catch (e) {
      print("❌ Error parsing user data: $e");
      print("❌ Raw response that failed to parse: $res");
      return [];
    }
  }
}
