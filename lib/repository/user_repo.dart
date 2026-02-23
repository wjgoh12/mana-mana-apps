import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/model/popout_notification.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  String _normalizeEmail(String? value) => (value ?? '').trim().toLowerCase();

  String? _extractEmailFromMap(Map<String, dynamic> data) {
    final ownersInfo = data['ownersinfo'];
    if (ownersInfo is Map<String, dynamic>) {
      final ownersEmail = ownersInfo['email']?.toString();
      if (ownersEmail != null && ownersEmail.isNotEmpty) {
        return ownersEmail;
      }
    }

    final directEmail = data['email']?.toString();
    if (directEmail != null && directEmail.isNotEmpty) {
      return directEmail;
    }

    final ownerEmail = data['ownerEmail']?.toString();
    if (ownerEmail != null && ownerEmail.isNotEmpty) {
      return ownerEmail;
    }

    final userId = data['userId']?.toString();
    if (userId != null && userId.contains('@')) {
      return userId;
    }

    return null;
  }

  String? _extractFirstEmail(dynamic response) {
    if (response is Map<String, dynamic>) {
      return _extractEmailFromMap(response);
    }

    if (response is List) {
      for (final item in response) {
        if (item is Map) {
          final email = _extractEmailFromMap(Map<String, dynamic>.from(item));
          if (email != null && email.isNotEmpty) {
            return email;
          }
        }
      }
    }

    return null;
  }

  bool _responseMatchesEmail(dynamic response, String targetEmail) {
    final normalizedTarget = _normalizeEmail(targetEmail);
    if (normalizedTarget.isEmpty) return false;

    if (response is Map<String, dynamic>) {
      final email = _extractEmailFromMap(response);
      return _normalizeEmail(email) == normalizedTarget;
    }

    if (response is List) {
      for (final item in response) {
        if (item is Map) {
          final email = _extractEmailFromMap(Map<String, dynamic>.from(item));
          if (_normalizeEmail(email) == normalizedTarget) {
            return true;
          }
        }
      }
      return false;
    }

    return false;
  }

  Future<List<User>> getUsers() async {
    return await _apiService.post(ApiEndpoint.ownerUserData).then((res) {
      try {
        if (res == null) {
          print("⚠️ API returned null for ownerUserData");
          return [];
        }
        // debugPrint(
        //     "✅ API call succeeded for ownerUserData; \nraw response: $res");
        print(res['ownersinfo']);

        if (res is String) {
          debugPrint(
              '🔧 getUsers response is malformed string, checking for token');

          final tokenRegex = RegExp(r'token:\s*([A-Za-z0-9_.-]+)');
          final tokenMatch = tokenRegex.firstMatch(res);

          if (tokenMatch != null) {
            final newToken = tokenMatch.group(1);
            debugPrint(
                '🔑 Found token in getUsers response: ${newToken?.substring(0, 20)}...');

            final AuthService authService = AuthService();
            authService.updateTokens(accessToken: newToken!);
            debugPrint('✅ Updated token from getUsers response');
          } else {
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

          debugPrint(
              '⚠️ getUsers returned malformed string, cannot parse user data properly');
          return [];
        }

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

        try {
          final serverUserId = userMap['userId']?.toString();
          final serverEmail = userMap['email']?.toString();
          final token = userMap['token']?.toString();
          debugPrint(
              '🔎 ownerUserData parsed: userId=$serverUserId, email=$serverEmail, token_present=${token != null}');

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

  Future<Map<String, dynamic>> validateSwitchUser(
      String switchUserEmail) async {
    try {
      final response = await _apiService.post(
        ApiEndpoint.validateUser,
        data: {'switchUserEmail': switchUserEmail},
      );

      debugPrint('🔁 validateSwitchUser response: $response');

      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is String) {
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

      // Server returns plain text for switch-user (session/cookie-based impersonation).
      // No new JWT token is issued — identity is managed server-side via session cookie.
      bool isSuccess = true;
      int statusCode = 200;

      if (response is Map<String, dynamic>) {
        final dynamic successValue = response['success'];
        if (successValue is bool) {
          isSuccess = successValue;
        }

        final dynamic statusValue =
            response['statusCode'] ?? response['status'];
        if (statusValue is int) {
          statusCode = statusValue;
          if (statusCode >= 400) isSuccess = false;
        }
      } else if (response is String) {
        final lower = response.toLowerCase();
        final hasKnownError = lower.contains('403') ||
            lower.contains('forbidden') ||
            lower.contains('not allowed') ||
            lower.contains('unauthorized') ||
            lower.contains('failed');
        if (hasKnownError) {
          isSuccess = false;
          statusCode = 403;
        }
      }

      debugPrint(
          '${isSuccess ? '✅' : '❌'} User switch confirm status: success=$isSuccess');

      return {
        'statusCode': statusCode,
        'success': isSuccess,
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

  Future<User?> getUserByEmail(String email) async {
    try {
      debugPrint('🔍 getUserByEmail: Fetching user for email: $email');

      final possiblePayloads = [
        {'switchUserEmail': email},
        {'ownerEmail': email},
        {'userEmail': email},
        {'email': email},
      ];

      dynamic res;
      for (final payload in possiblePayloads) {
        try {
          debugPrint('🔍 Trying payload: $payload');
          final attempt = await _apiService.post(
            ApiEndpoint.ownerUserData,
            data: payload,
          );

          if (attempt == null) {
            continue;
          }

          final resolvedEmail = _extractFirstEmail(attempt);
          final isMatch = _responseMatchesEmail(attempt, email);
          debugPrint(
              '🔍 Payload $payload resolvedEmail=$resolvedEmail, match=$isMatch');

          if (isMatch) {
            res = attempt;
            break;
          }

          // Keep first non-null response as a last-resort fallback.
          res ??= attempt;
        } catch (e) {
          debugPrint('⚠️ Failed with payload $payload: $e');
        }
      }

      if (res != null && !_responseMatchesEmail(res, email)) {
        final fallbackEmail = _extractFirstEmail(res);
        debugPrint(
            '⚠️ getUserByEmail payload probes did not match target=$email (got=$fallbackEmail). Falling back to local search.');
        res = null;
      }

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

      try {
        if (res is List && res.isNotEmpty) {
          debugPrint('📋 Response is a List with ${res.length} items');
          for (final item in res) {
            if (item is! Map) continue;
            final user = User.fromJson(Map<String, dynamic>.from(item));
            final parsedEmail =
                _normalizeEmail(user.email ?? user.ownerEmail ?? '');
            if (parsedEmail == _normalizeEmail(email)) {
              debugPrint('✅ Parsed matching user from list: ${user.email}');
              return user;
            }
          }
          debugPrint('⚠️ No matching user found in list for email=$email');
          return null;
        }

        if (res is Map<String, dynamic>) {
          debugPrint('📦 Response is a Map');
          final user = User.fromJson(res);
          debugPrint('✅ Parsed user from map: ${user.email}');

          final parsedEmail = _normalizeEmail(user.email ?? user.ownerEmail);
          if (parsedEmail == _normalizeEmail(email)) {
            return user;
          }
          debugPrint('⚠️ Email mismatch: got ${user.email}, expected $email');
          return null;
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
    final possiblePayloads = [
      {'switchUserEmail': email},
      {'ownerEmail': email},
      {'userEmail': email},
      {'email': email},
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

        if (attempt == null) {
          continue;
        }

        final resolvedEmail = _extractFirstEmail(attempt);
        final isMatch = _responseMatchesEmail(attempt, email);
        debugPrint(
            '🔁 Payload $payload resolvedEmail=$resolvedEmail, match=$isMatch');

        if (isMatch) {
          res = attempt;
          break;
        }
      } catch (e) {
        debugPrint('⚠️ getSwitchedUser attempt failed for $payload: $e');
      }
    }

    if (res == null) {
      try {
        debugPrint('🔁 No payloads succeeded; trying empty body');
        final attempt = await _apiService.post(
          ApiEndpoint.ownerUserData,
        );
        if (attempt != null && _responseMatchesEmail(attempt, email)) {
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
      // debugPrint(
      //     "✅ API call succeeded for switched ownerUserData; raw response: $res");

      Map<String, dynamic> userMap;
      if (res is List && res.isNotEmpty) {
        Map<String, dynamic>? match;
        for (final item in res) {
          if (item is! Map) continue;
          final mapItem = Map<String, dynamic>.from(item);
          if (_responseMatchesEmail(mapItem, email)) {
            match = mapItem;
            break;
          }
        }
        if (match == null) {
          debugPrint(
              '⚠️ getSwitchedUser list response did not contain target email=$email');
          return [];
        }
        userMap = match;
      } else if (res is Map<String, dynamic>) {
        if (!_responseMatchesEmail(res, email)) {
          final resolvedEmail = _extractEmailFromMap(res);
          debugPrint(
              '⚠️ getSwitchedUser map response email mismatch: expected=$email, got=$resolvedEmail');
          return [];
        }
        userMap = res;
      } else {
        debugPrint(
            '❌ Unexpected response type for ownerUserData: ${res.runtimeType}');
        return [];
      }

      final user = User.fromJson(userMap);

      try {
        final serverUserId = userMap['userId']?.toString();
        final serverEmail = userMap['email']?.toString();
        final token = userMap['token']?.toString();
        debugPrint(
            '🔎 getSwitchedUser parsed: userId=$serverUserId, email=$serverEmail, token_present=${token != null}');

        if (token != null && token.isNotEmpty) {
          try {
            final parts = token.split('.');
            if (parts.length >= 2) {
              final normalized = base64Url.normalize(parts[1]);
              final decoded = utf8.decode(base64Url.decode(normalized));
              // debugPrint('🔐 token payload: $decoded');
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

  Future<List<PopoutNotification>> getPopoutNotifications() async {
    try {
      final response = await _apiService.get(ApiEndpoint.getPopout);

      if (response != null && response is List) {
        return response
            .map((e) => PopoutNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
