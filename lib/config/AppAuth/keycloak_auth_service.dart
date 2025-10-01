import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mana_mana_app/splashscreen.dart';
import '../env_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Timer? _refreshTimer;
  bool _isRefreshing = false;
  
  // Add a global navigation key reference
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  // Method to set the navigator key from main app
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }
  
  // Method to handle session expiry globally
  void _handleSessionExpiry() {
    print('🚪 Session expired - navigating to login');
    if (_navigatorKey?.currentContext != null) {
      Navigator.of(_navigatorKey!.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Splashscreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Method to handle server authentication failures (401/403 responses)
  Future<void> handleServerAuthenticationFailure() async {
    print('🚫 Server rejected authentication - clearing tokens and redirecting to login');
    await _removeAllAppData();
    _handleSessionExpiry();
  }

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

        _startTokenRefreshTimer(result.accessToken!);
        return true;
      }
    } catch (e) {
      print('❌ Authentication error: $e');
    }
    return false;
  }

  Future<bool> checkToken() async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print('⚠️ No access token found - user needs to login');
      return false; // Don't automatically authenticate, let the app handle login UI
    }

    Duration remaining = JwtDecoder.getRemainingTime(accessToken);
    print(
        '⏰ Token expires in: ${remaining.inMinutes}m ${remaining.inSeconds % 60}s');

    bool tokenValid = await validateToken(accessToken);
    if (!tokenValid) {
      print('🔄 Token invalid or near expiry, refreshing...');
      bool refreshed = await refreshTokenFunction();
      if (!refreshed) {
        print('❌ Failed to refresh token - user needs to re-login');
        return false;
      }
      return true;
    }

    // Token is valid, start the refresh timer
    _startTokenRefreshTimer(accessToken);
    return true;
  }

  Future<String?> getValidAccessToken() async {
  String? accessToken = await getAccessToken();
  String? refreshToken = await _secureStorage.read(key: 'refresh_token');

  if (accessToken == null || refreshToken == null) {
    print('❌ Missing tokens - need to login');
    return null;
  }

  // Check if refresh token is expired first
  try {
    if (JwtDecoder.isExpired(refreshToken)) {
      print('❌ Refresh token expired - need to re-login');
      await _removeAllAppData();
      _handleSessionExpiry();
      return null;
    }
  } catch (e) {
    print('❌ Error checking refresh token: $e');
    await _removeAllAppData();
    _handleSessionExpiry();
    return null;
  }

  // Check access token
  if (JwtDecoder.isExpired(accessToken) ||
      JwtDecoder.getRemainingTime(accessToken).inSeconds <= 60) {
    print('🔄 Access token expired/expiring, refreshing...');
    bool refreshed = await refreshTokenFunction();

    if (refreshed) {
      accessToken = await getAccessToken();
    } else {
      print('❌ Token refresh failed - need to re-login');
      await _removeAllAppData();
      _handleSessionExpiry();
      return null;
    }
  }

  return accessToken;
}

  Future<bool> isLoggedIn() async {
    try {
      String? validToken = await getValidAccessToken();
      if (validToken != null) {
        _startTokenRefreshTimer(validToken); // Still keep timer as backup
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Modify existing methods to use detection-based approach
  Future<bool> validateToken(String token) async {
    try {
      // Simply check if token is expired
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _refreshTimer?.cancel();

    String? refreshToken = await _secureStorage.read(key: 'refresh_token');
    String? accessToken = await _secureStorage.read(key: 'access_token');

    try {
      if (refreshToken != null) {
        final apiLogoutUrl =
            '${EnvConfig.apiBaseUrl}/mobile/dash/refs/logout?refToken=$refreshToken';

        await http.post(
          Uri.parse(apiLogoutUrl),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
      }

      final keycloakLogoutUrl =
          '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/protocol/openid-connect/logout';

      await http.post(
        Uri.parse(keycloakLogoutUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'post_logout_redirect_uri': EnvConfig.keycloakRedirectUrl,
          'client_id': EnvConfig.keycloakClientId,
          'refresh_token': refreshToken,
          'client_secret': EnvConfig.keycloakClientSecret,
        },
      );
    } catch (e) {
      //print('❌ Logout error: $e');
    }

    await _removeAllAppData();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Splashscreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _removeAllAppData() async {
    await _secureStorage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> _startTokenRefreshTimer(String accessToken) async {
    _refreshTimer?.cancel();

    try {
      DateTime expiryDate = JwtDecoder.getExpirationDate(accessToken);
      Duration timeUntilExpiry = expiryDate.difference(DateTime.now());
      Duration refreshBefore = const Duration(minutes: 1);
      Duration refreshIn = timeUntilExpiry - refreshBefore;

      if (refreshIn.isNegative) {
        //print('⚠️ Token already expired or near expiry, refreshing now.');
        await refreshTokenFunction();
        return;
      }

      _refreshTimer = Timer(refreshIn, () async {
        //print('⏱️ Timer triggered token refresh');
        await refreshTokenFunction();
      });

      //print('🕒 Refresh timer set for ${refreshIn.inSeconds} seconds');
    } catch (e) {
      //print('❌ Failed to set refresh timer: $e');
    }
  }

  Future<bool> refreshTokenFunction() async {
  if (_isRefreshing) {
    print('⏳ Already refreshing...');
    return false;
  }

  _isRefreshing = true;

  try {
    final String? refreshToken =
        await _secureStorage.read(key: 'refresh_token');

    if (refreshToken == null) {
      print('❌ No refresh token available.');
      _isRefreshing = false;
      return false;
    }

    // Check refresh token expiry before using it
    if (JwtDecoder.isExpired(refreshToken)) {
      print('❌ Refresh token expired - clearing tokens');
      await _removeAllAppData();
      _handleSessionExpiry();
      _isRefreshing = false;
      return false;
    }

    final Uri tokenEndpoint = Uri.parse(
        '${EnvConfig.keycloakBaseUrl}/auth/realms/mana/protocol/openid-connect/token');

    final response = await http.post(
      tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': EnvConfig.keycloakClientId,
        'client_secret': EnvConfig.keycloakClientSecret,
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> tokenData = json.decode(response.body);

      // Store new tokens
      await _secureStorage.write(
          key: 'access_token', value: tokenData['access_token']);

      if (tokenData['refresh_token'] != null) {
        await _secureStorage.write(
            key: 'refresh_token', value: tokenData['refresh_token']);
      }

      // Start new timer with the new token
      _startTokenRefreshTimer(tokenData['access_token']);

      print('✅ Token refreshed successfully');
      _isRefreshing = false;
      return true;
    } else {
      print('❌ Token refresh failed: ${response.statusCode} - ${response.body}');
      
      // If refresh fails, likely means refresh token is invalid/expired
      if (response.statusCode == 400 || response.statusCode == 401) {
        await _removeAllAppData();
        _handleSessionExpiry();
      }
      
      _isRefreshing = false;
      return false;
    }
  } catch (e) {
    print('❌ Token refresh error: $e');
    _isRefreshing = false;
    return false;
  }
}
}