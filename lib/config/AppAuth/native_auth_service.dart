import 'dart:convert';
import 'dart:math' show min;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../env_config.dart';
import 'keycloak_auth_service.dart';

class NativeAuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Authenticate user with username and password directly to Keycloak
  Future<AuthResult> authenticate(String username, String password) async {
    try {
      final Uri tokenEndpoint = Uri.parse(
          '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/protocol/openid-connect/token');

      final response = await http.post(
        tokenEndpoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': EnvConfig.keycloakClientId,
          'client_secret': EnvConfig.keycloakClientSecret,
          'username': username,
          'password': password,
          'scope': 'openid profile email',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);

        // Store tokens securely
        await _secureStorage.write(
            key: 'access_token', value: tokenData['access_token']);
        await _secureStorage.write(
            key: 'refresh_token', value: tokenData['refresh_token']);

        // Initialize the main auth service with these tokens
        final authService = AuthService();
        await authService.initializeTokensFromNativeLogin(
            tokenData['access_token'], tokenData['refresh_token']);

        return AuthResult(
          success: true,
          accessToken: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'],
          message: 'Login successful',
        );
      } else if (response.statusCode == 401) {
        // Invalid credentials
        return AuthResult(
          success: false,
          message: 'Invalid username or password',
        );
      } else {
        // Other errors
        final Map<String, dynamic> errorData = json.decode(response.body);
        return AuthResult(
          success: false,
          message: errorData['error_description'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: Please check your connection',
      );
    }
  }

  /// Request password reset for a user email - sends email directly to user
  Future<AuthResult> requestPasswordReset(String email) async {
    try {
      // Simulate what happens when user clicks "Forgot Password" on Keycloak login page
      // This is the most reliable method

      final result = await _simulateWebForgotPassword(email);
      if (result != null) return result;

      // If simulation doesn't work, inform user about alternative
      return AuthResult(
        success: false,
        message:
            'Unable to automatically send reset email. Please contact your administrator or use the web portal to reset your password.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: Please check your connection and try again.',
      );
    }
  }

  /// Simulate the web browser forgot password flow
  Future<AuthResult?> _simulateWebForgotPassword(String email) async {
    try {
      // Direct approach: Go straight to the forgot password page
      final forgotPasswordUrl = Uri.parse(
          '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/login-actions/reset-credentials'
          '?client_id=${EnvConfig.keycloakClientId}');

      final forgotResponse = await http.get(forgotPasswordUrl);

      if (forgotResponse.statusCode != 200) {
        return await _tryDirectResetEmail(email);
      }

      // Extract all form parameters from the HTML
      String htmlBody = forgotResponse.body;

      // Debug: Print form section of HTML
      final formMatch =
          RegExp(r'<form[^>]*action="([^"]*)"[^>]*>', caseSensitive: false)
              .firstMatch(htmlBody);
      if (formMatch != null) {
        final actionUrl = formMatch.group(1)!;
      } else {}

      // Extract parameters from the form action URL
      String? sessionCode;
      String? execution;
      String? tabId;
      String? clientData;
      Uri? postUrl;

      if (formMatch != null) {
        // Decode HTML entities (&amp; -> &, &quot; -> ", etc.)
        var actionUrl = formMatch
            .group(1)!
            .replaceAll('&amp;', '&')
            .replaceAll('&quot;', '"')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>');

        // Parse all URL parameters from the action
        final uri = Uri.parse(actionUrl);
        postUrl = uri; // Use the complete URL from the form action
        sessionCode = uri.queryParameters['session_code'];
        execution = uri.queryParameters['execution'];
        tabId = uri.queryParameters['tab_id'];
        clientData = uri.queryParameters['client_data'];
      }

      if (sessionCode == null || sessionCode.isEmpty) {
        return await _tryDirectResetEmail(email);
      }

      if (execution == null || execution.isEmpty) {
        return await _tryDirectResetEmail(email);
      }

      if (postUrl == null) {
        return await _tryDirectResetEmail(email);
      }

      // Extract cookies
      final cookies = forgotResponse.headers['set-cookie'] ?? '';

      // Step 2: POST the email to trigger reset
      // Use the exact URL from the form action
      final postBody = <String, String>{
        'username': email,
      };

      final resetResponse = await http.post(
        postUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': cookies,
        },
        body: postBody,
      );

      // Check for error messages in the response
      final responseBody = resetResponse.body.toLowerCase();

      // Check for user not found error
      if (responseBody.contains('user not found') ||
          responseBody.contains('user does not exist') ||
          responseBody.contains('invalid username')) {
        return AuthResult(
          success: false,
          message:
              'No account found with this email address. Please check your email or contact support.',
        );
      }

      // Check for other error messages
      if (responseBody.contains('error') &&
          (responseBody.contains('invalid') ||
              responseBody.contains('failed'))) {
        // Extract error message from HTML if possible
        final errorMatch = RegExp(r'class="[^"]*error[^"]*"[^>]*>([^<]+)<',
                caseSensitive: false)
            .firstMatch(resetResponse.body);
        final errorMsg = errorMatch?.group(1)?.trim();

        if (errorMsg != null && errorMsg.isNotEmpty) {
          return AuthResult(
            success: false,
            message: errorMsg,
          );
        }
      }

      // Success indicators
      if (resetResponse.statusCode == 200 ||
          resetResponse.statusCode == 302 ||
          resetResponse.statusCode == 303) {
        // Check if response contains success message
        if (responseBody.contains('email') ||
            responseBody.contains('instruction') ||
            responseBody.contains('sent') ||
            responseBody.contains('check your email') ||
            resetResponse.statusCode == 302 ||
            resetResponse.statusCode == 303) {
          return AuthResult(
            success: true,
            message:
                'If an account exists with the email address you entered, a password reset link has been sent.\n\nPlease check your inbox and spam/junk folder for the email.\n\nIf you don’t receive the message within a few minutes, it’s possible that no account is associated with that email address.',
          );
        }
      }

      // If we get here, try the fallback
      return await _tryDirectResetEmail(email);
    } catch (e) {
      return await _tryDirectResetEmail(email);
    }
  }

  /// Direct approach without session (might not work on all Keycloak versions)
  Future<AuthResult?> _tryDirectResetEmail(String email) async {
    try {
      final resetUrl = Uri.parse(
          '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/login-actions/reset-credentials');

      final response = await http.post(
        resetUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,
        },
      );

      // Even if we get an error, Keycloak might still send the email (for security)
      if (response.statusCode >= 200 && response.statusCode < 500) {
        return AuthResult(
          success: true,
          message:
              'If an account exists with this email, password reset instructions have been sent.',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate if user has valid stored tokens
  Future<bool> hasValidSession() async {
    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');
      String? refreshToken = await _secureStorage.read(key: 'refresh_token');

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // Check if refresh token is still valid
      if (JwtDecoder.isExpired(refreshToken)) {
        // Refresh token expired, clear all tokens
        await _clearTokens();
        return false;
      }

      // If access token is expired but refresh token is valid,
      // we can refresh it (this will be handled by AuthService)
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  /// Get user info from access token
  Map<String, dynamic>? getUserInfo() {
    try {
      // This would need to be called after successful authentication
      // You can decode the JWT token to get user information
      return null; // Implement based on your token structure
    } catch (e) {
      return null;
    }
  }
}

class AuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String message;

  AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    required this.message,
  });
}
