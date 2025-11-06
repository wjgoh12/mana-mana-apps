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
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    return await _apiService.post(ApiEndpoint.ownerUserData).then((res) {
      try {
        if (res == null) {
          print("⚠️ API returned null for ownerUserData");
          return [];
        }
        debugPrint(
            "✅ API call succeeded for ownerUserData; \nraw response: $res");
        print(res['ownersinfo']);

        // NEW: Check if response is a malformed string and extract token if present
        if (res is String) {
          debugPrint(
              '🔧 getUsers response is malformed string, checking for token');

          // Look for JWT token pattern in the string
          final tokenRegex = RegExp(r'token:\s*([A-Za-z0-9_.-]+)');
          final tokenMatch = tokenRegex.firstMatch(res);

          if (tokenMatch != null) {
            final newToken = tokenMatch.group(1);
            debugPrint(
                '🔑 Found token in getUsers response: ${newToken?.substring(0, 20)}...');

            // Update stored token
            final AuthService authService = AuthService();
            authService.updateTokens(accessToken: newToken!);
            debugPrint('✅ Updated token from getUsers response');
          } else {
            // Try alternative pattern
            final altTokenRegex = RegExp(r'eyJ[A-Za-z0-9_.-]+');
            final altTokenMatch = altTokenRegex.firstMatch(res);

            if (altTokenMatch != null) {
              final newToken = altTokenMatch.group(0);
              debugPrint(
                  '🔑 Found token using alt pattern in getUsers: ${newToken?.substring(0, 20)}...');

              final AuthService authService = AuthService();
              authService.updateTokens(accessToken: newToken!);
              debugPrint('✅ Updated token from getUsers response');
            }
          }

          // For malformed string, try to parse user data from it
          // This is a fallback - the response should be proper JSON
          debugPrint(
              '⚠️ getUsers returned malformed string, cannot parse user data properly');
          return [];
        }

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

          // If there's a token in the response, update it
          if (token != null && token.isNotEmpty) {
            debugPrint(
                '🔑 Found token in getUsers JSON response, updating stored token');
            final AuthService authService = AuthService();
            authService.updateTokens(accessToken: token);
            debugPrint('✅ Updated token from getUsers JSON response');
          }
        } catch (_) {}

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

  Future<Map<String, dynamic>> confirmSwitchUser(String switchUserEmail) async {
    try {
      final response = await _apiService.post(ApiEndpoint.confirmUser, data: {
        "switchUserEmail": switchUserEmail,
      });
      debugPrint('🔁 confirmSwitchUser response: $response');

      // The confirmUser API just returns a confirmation message
      // The actual token switching happens when we call getUsers()
      debugPrint('� User switch confirmed, now fetching updated user data...');

      return {
        'statusCode': 200,
        'success': true,
        'body': response,
      };
    } catch (e) {
      debugPrint('❌ confirmSwitchUser error: $e');
      return {
        'statusCode': 500,
        'success': false,
        'body': e.toString(),
      };
    }
  }

  Future<void> cancelSwitchUser(String email) async {
    final response =
        await _apiService.post(ApiEndpoint.cancelSwitchUser, data: {
      "switchUserEmail": email,
    });
    print('🔁 cancelSwitchUser response: $response');
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

      debugPrint("Successfully parsed switched user: ${user.ownerEmail}");
      return [user];
    } catch (e) {
      print("❌ Error parsing user data: $e");
      print("❌ Raw response that failed to parse: $res");
      return [];
    }
  }
}
