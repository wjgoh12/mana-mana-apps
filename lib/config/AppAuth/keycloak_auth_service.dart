import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import '../env_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final UserRepository user_repository = UserRepository();
  Future<bool> authenticate() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EnvConfig.keycloak_clientId,
          EnvConfig.keycloak_redirectUrl,
          discoveryUrl: EnvConfig.keycloak_discoveryUrl,
          clientSecret: EnvConfig.keycloak_clientSecret,
          scopes: ['openid', 'profile', 'email'],
          preferEphemeralSession: true,
          allowInsecureConnections: true,
          
        ),
      );
      
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
    String? token = await _secureStorage.read(key: 'refresh_token');
    final String url = 'http://192.168.0.210:7082/auth/realms/mana/protocol/openid-connect/logout';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'post_logout_redirect_uri': EnvConfig.keycloak_redirectUrl, // Optional: URL to redirect after logout
      'client_id': EnvConfig.keycloak_clientId, // Optional: Client ID if required
      'refresh_token': token, // Use the refresh token for the logout
      'client_secret': EnvConfig.keycloak_clientSecret
    },
  );

  if (response.statusCode == 200) {
    print('Logout successful');
  } else {
    print('Failed to logout: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
    await user_repository.logoutFunc();
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
          EnvConfig.keycloak_clientId,
          EnvConfig.keycloak_redirectUrl,
          discoveryUrl: EnvConfig.keycloak_discoveryUrl,
          clientSecret: EnvConfig.keycloak_clientSecret,
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