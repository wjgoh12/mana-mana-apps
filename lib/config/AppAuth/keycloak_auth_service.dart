import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:mana_mana_app/splashscreen.dart';
import 'package:path_provider/path_provider.dart';
import '../env_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final UserRepository user_repository = UserRepository();

  DateTime? _tokenExpiryTime;
  Timer? _refreshTimer;

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
        await _secureStorage.write(
            key: 'access_token', value: result.accessToken);
        await _secureStorage.write(
            key: 'refresh_token', value: result.refreshToken);
        // Calculate the token expiration time and start the timer
        _tokenExpiryTime = DateTime.now().add(Duration(
            minutes:
                EnvConfig.tokenExpirationMinutes)); // Set expiry to 20 minutes
        _startTokenRefreshTimer();
        return true;
      }
    } catch (e) {
      print('Error during authentication: $e');
    }
    return false;
  }

  void _startTokenRefreshTimer() {
    final timeUntilExpiry = _tokenExpiryTime!.difference(DateTime.now());
    final refreshTime = timeUntilExpiry -
        Duration(minutes: 5); // Refresh 5 minutes before expiry

    _refreshTimer?.cancel(); // Cancel any existing timer
    _refreshTimer = Timer(refreshTime, () {
      refreshToken();
    });
  }

  Future<bool> checkToken() async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      return await authenticate();
    }
    bool tokenValid = await validateToken(accessToken);
    if (!tokenValid) {
      return await refreshToken();
    }
    return true;
  }

  Future<bool> validateToken(String token) async {
    // Implement token validation logic here
    return true;
  }

  Future<void> logout(BuildContext context) async {
    _refreshTimer?.cancel(); // Cancel the refresh timer on logout

    String? token = await _secureStorage.read(key: 'refresh_token');
    if (token != null) {
      final String url =
          '${EnvConfig.api_baseUrl}/mobile/dash/refs/logout?refToken=${token}';
      String? accessToken = await _secureStorage.read(key: 'access_token');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          print('API Logout successful');
        } else {
          print('Failed to logout: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error during logout: $e');
      }
    } else {
      print('No refresh token found');
    }

    final String url =
        '${EnvConfig.keycloak_baseUrl}/auth/realms/mana/protocol/openid-connect/logout';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'post_logout_redirect_uri': EnvConfig.keycloak_redirectUrl,
        'client_id': EnvConfig.keycloak_clientId,
        'refresh_token': token,
        'client_secret': EnvConfig.keycloak_clientSecret,
      },
    );
    print('Response status code: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Keycloak Logout successful');
      await _removeAllAppData();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Splashscreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Failed to logout: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _removeAllAppData() async {
    await _secureStorage.deleteAll();

    // final cacheDir = await getTemporaryDirectory();
    // if (cacheDir.existsSync()) {
    //   cacheDir.deleteSync(recursive: true);
    // }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<bool> refreshToken() async {
    try {
      final String? refreshToken =
          await _secureStorage.read(key: 'refresh_token');
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
        await _secureStorage.write(
            key: 'refresh_token', value: result.refreshToken);
        await _secureStorage.write(
            key: 'access_token', value: result.accessToken);
        // Update the token expiry time and restart the timer
        _tokenExpiryTime = DateTime.now().add(Duration(
            minutes: EnvConfig
                .tokenExpirationMinutes)); // Reset expiry to 20 minutes
        _startTokenRefreshTimer();
        return true;
      }
    } catch (e, s) {
      print('Refresh token error: $e - stack: $s');
    }
    return false;
  }
}
