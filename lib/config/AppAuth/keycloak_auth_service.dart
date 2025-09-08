import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/splashscreen.dart';
import '../env_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // DateTime? _tokenExpiryTime;
  Timer? _refreshTimer;

  Future<bool> authenticate() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EnvConfig.keycloakClientId,
          EnvConfig.keycloakRedirectUrl,
          discoveryUrl: EnvConfig.keycloakDiscoveryUrl,
          clientSecret: EnvConfig.keycloakClientSecret,
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
        // _tokenExpiryTime = DateTime.now().add(const Duration(
        //     minutes:
        //         EnvConfig.tokenExpirationMinutes)); // Set expiry to 20 minutes
        return true;
      }
    } catch (e) {
      // print('Error during authentication: $e');
    }
    return false;
  }

  Future<bool> checkToken() async {
    String? accessToken = await getAccessToken();
    // print(JwtDecoder.getRemainingTime(accessToken!));
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
    try {
      if (!JwtDecoder.isExpired(token)) {
        // Get remaining time before token expires
        Duration timeUntilExpiry = JwtDecoder.getRemainingTime(token);

        // If token expires in less than 5 minutes, consider it invalid
        if (timeUntilExpiry.inMinutes <= 3) {
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _refreshTimer?.cancel(); // Cancel the refresh timer on logout

    String? token = await _secureStorage.read(key: 'refresh_token');
    if (token != null) {
      final String url =
          '${EnvConfig.apiBaseUrl}/mobile/dash/refs/logout?refToken=$token';
      String? accessToken = await _secureStorage.read(key: 'access_token');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          // print('API Logout successful');
        } else {
          // print('Failed to logout: ${response.statusCode}');
          // print('Response body: ${response.body}');
        }
      } catch (e) {
        // print('Error during logout: $e');
      }
    } else {
      // print('No refresh token found');
    }

    final String url =
        '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/protocol/openid-connect/logout';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'post_logout_redirect_uri': EnvConfig.keycloakRedirectUrl,
        'client_id': EnvConfig.keycloakClientId,
        'refresh_token': token,
        'client_secret': EnvConfig.keycloakClientSecret,
      },
    );
    // print('Response status code: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      // print('Keycloak Logout successful');
      await _removeAllAppData();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Splashscreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // print('Failed to logout: ${response.statusCode}');
      // print('Response body: ${response.body}');
    }
  }

  Future<void> _removeAllAppData() async {
    await _secureStorage.deleteAll();
    
    // Clear all cached data from GlobalDataManager
    final globalDataManager = GlobalDataManager();
    globalDataManager.clearAllData();

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
          EnvConfig.keycloakClientId,
          EnvConfig.keycloakRedirectUrl,
          discoveryUrl: EnvConfig.keycloakDiscoveryUrl,
          clientSecret: EnvConfig.keycloakClientSecret,
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
        // _tokenExpiryTime = DateTime.now().add(const Duration(
        //     minutes: EnvConfig
        //         .tokenExpirationMinutes)); // Reset expiry to 20 minutes
        return true;
      }
    } catch (e) {
      // print('Refresh token error: $e');
    }
    return false;
  }
}
