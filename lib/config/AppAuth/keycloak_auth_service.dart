import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'keycloak_config.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<bool> authenticate() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          KeycloakConfig.clientId,
          KeycloakConfig.redirectUrl,
          discoveryUrl: KeycloakConfig.discoveryUrl,
          clientSecret: KeycloakConfig.clientSecret,
          scopes: ['openid', 'profile', 'email'],
          preferEphemeralSession: true,
          allowInsecureConnections: true,
          
        ),
      );
      print(result);
      if (result != null) {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken);
        return true;
      }
    } catch (e) {
      print('Error during authentication: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<bool> refreshToken() async {
    try {
      final String? refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          KeycloakConfig.clientId,
          KeycloakConfig.redirectUrl,
          discoveryUrl: KeycloakConfig.discoveryUrl,
          refreshToken: refreshToken,
          scopes: ['openid', 'profile', 'email'],
        ),
      );

      if (result != null) {
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken);
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        return true;
      }
    } catch (e, s) {
      print('Refresh token error: $e - stack: $s');
    }
    return false;
  }
}