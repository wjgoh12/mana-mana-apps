import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mana_mana_app/config/env_config.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';

/// OAuth2Provider — Admin token backup/restore for switch user impersonation.
///
/// On PWA, the switch user flow uses the server's session-based impersonation
/// (`/admin/switch-user` endpoint). This provider handles saving the admin's
/// original tokens before switching, so they can be restored when the admin
/// clicks "Revert" / "Switch Back".
///
/// Usage:
/// ```dart
/// // Before switching: save admin tokens
/// await OAuth2Provider.instance.saveAdminSession();
///
/// // When switching back: restore admin tokens
/// await OAuth2Provider.instance.switchBack();
/// ```
class OAuth2Provider {
  // ─── Singleton ─────────────────────────────────────────────────────
  static final OAuth2Provider instance = OAuth2Provider._internal();
  OAuth2Provider._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Secure storage keys for the admin's original tokens
  static const String _keyAdminAccessToken = 'admin_original_access_token';
  static const String _keyAdminRefreshToken = 'admin_original_refresh_token';
  static const String _keyImpersonatedEmail = 'impersonated_user_email';

  // ─── Getters ───────────────────────────────────────────────────────

  /// Whether the admin is currently impersonating another user.
  Future<bool> get isImpersonating async {
    final email = await _secureStorage.read(key: _keyImpersonatedEmail);
    return email != null && email.isNotEmpty;
  }

  /// The email of the user currently being impersonated, or null.
  Future<String?> get impersonatedEmail async {
    return await _secureStorage.read(key: _keyImpersonatedEmail);
  }

  // ─── Save Admin Session ────────────────────────────────────────────

  /// Save the admin's current tokens before switching to another user.
  ///
  /// Call this BEFORE the server-side switch-user endpoint is called,
  /// so we can restore the admin's session later via [switchBack].
  Future<bool> saveAdminSession() async {
    try {
      final authService = AuthService();
      final adminAccessToken = await authService.getValidAccessToken();

      if (adminAccessToken == null) {
        debugPrint('⚠️ OAuth2Provider: No valid admin token to save');
        return false;
      }

      final adminRefreshToken =
          await _secureStorage.read(key: 'refresh_token');

      await _secureStorage.write(
          key: _keyAdminAccessToken, value: adminAccessToken);
      if (adminRefreshToken != null) {
        await _secureStorage.write(
            key: _keyAdminRefreshToken, value: adminRefreshToken);
      }

      debugPrint('✅ OAuth2Provider: Admin session saved for later restore');
      return true;
    } catch (e) {
      debugPrint('❌ OAuth2Provider: Failed to save admin session: $e');
      return false;
    }
  }

  /// Mark the impersonated user email (for state tracking).
  Future<void> setImpersonatedEmail(String email) async {
    await _secureStorage.write(key: _keyImpersonatedEmail, value: email);
  }

  // ─── Switch Back ───────────────────────────────────────────────────

  /// Restore the admin's original session tokens.
  ///
  /// Call this when the admin clicks "Revert" / "Switch Back".
  /// Returns `true` if the admin session was successfully restored.
  Future<bool> switchBack() async {
    try {
      final adminAccessToken =
          await _secureStorage.read(key: _keyAdminAccessToken);
      final adminRefreshToken =
          await _secureStorage.read(key: _keyAdminRefreshToken);

      if (adminAccessToken == null && adminRefreshToken == null) {
        debugPrint(
            '⚠️ OAuth2Provider: No saved admin tokens to restore');
        return false;
      }

      final authService = AuthService();

      // Check if the saved admin access token is still valid
      bool accessTokenValid = false;
      if (adminAccessToken != null) {
        try {
          accessTokenValid = !JwtDecoder.isExpired(adminAccessToken);
        } catch (_) {}
      }

      if (accessTokenValid) {
        // Restore directly — the admin's access token is still good
        await authService.updateTokens(
          accessToken: adminAccessToken!,
          refreshToken: adminRefreshToken,
        );
        debugPrint(
            '✅ OAuth2Provider: Admin session restored from saved token');
      } else if (adminRefreshToken != null) {
        // Access token expired but refresh token might still work
        debugPrint(
            '🔄 OAuth2Provider: Admin access token expired, refreshing...');

        final tokenEndpoint = Uri.parse(
            '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/protocol/openid-connect/token');

        final response = await http.post(
          tokenEndpoint,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'refresh_token',
            'client_id': EnvConfig.keycloakClientId,
            'client_secret': EnvConfig.keycloakClientSecret,
            'refresh_token': adminRefreshToken,
          },
        );

        if (response.statusCode == 200) {
          final tokenData =
              json.decode(response.body) as Map<String, dynamic>;
          await authService.updateTokens(
            accessToken: tokenData['access_token'],
            refreshToken: tokenData['refresh_token'],
          );
          debugPrint(
              '✅ OAuth2Provider: Admin session restored via refresh token');
        } else {
          debugPrint(
              '❌ OAuth2Provider: Failed to refresh admin token (${response.statusCode}). Admin must re-login.');
          await _clearAll();
          return false;
        }
      } else {
        debugPrint(
            '❌ OAuth2Provider: No valid admin tokens available. Admin must re-login.');
        await _clearAll();
        return false;
      }

      // Clear impersonation state
      await _clearAll();
      return true;
    } catch (e) {
      debugPrint('❌ OAuth2Provider: switchBack error: $e');
      await _clearAll();
      return false;
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────

  /// Clear all impersonation state. Called on logout or when impersonation ends.
  Future<void> clearImpersonationState() async {
    await _clearAll();
  }

  Future<void> _clearAll() async {
    await _secureStorage.delete(key: _keyAdminAccessToken);
    await _secureStorage.delete(key: _keyAdminRefreshToken);
    await _secureStorage.delete(key: _keyImpersonatedEmail);
  }
}
