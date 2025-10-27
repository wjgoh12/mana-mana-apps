import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/env_config.dart';

// Custom exception for authentication failures
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class ApiService {
  final String baseUrl = EnvConfig.apiBaseUrl;

  Future<dynamic> post(String url, {Map<String, dynamic>? data}) async {
    final AuthService authService = AuthService();
    String? token = await authService.getValidAccessToken();

    if (token == null) {
      print('❌ No valid token available for API call - session expired');
      throw AuthenticationException('Session expired');
    }

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data ?? {}), // always send at least {}
    );

    // Check for authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('❌ API authentication failed - server rejected token');
      // Clear tokens and trigger session expiry handling
      await authService.handleServerAuthenticationFailure();
      throw AuthenticationException('Authentication failed');
    }

    if (response.body.isEmpty) return null;
    // debugPrint("➡️ FULL URL: $baseUrl$url");
    // debugPrint("➡️ POST BYTES URL: $baseUrl$url");
    try {
      return json.decode(response.body);
    } catch (e) {
      // If the response isn't JSON (plain text like "Now viewing as: ..."),
      // return the raw body so callers can parse or inspect it.
      debugPrint("❌ JSON decode error (returning raw body): $e");
      return response.body;
    }
  }

  Future<dynamic> postWithBytes(String url,
      {Map<String, dynamic>? data}) async {
    final AuthService authService = AuthService();
    bool isTokenValid = await authService.checkToken();
    if (!isTokenValid) {
      throw Exception('Authentication required');
    }
    String? token = await authService.getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.body.toString().contains("Incorrect result size")) {
      return 'Incorrect result size';
    } else {
      return response.bodyBytes;
    }
  }

  Future<dynamic> postJson(String url, {Map<String, dynamic>? data}) async {
    final AuthService authService = AuthService();
    String? token = await authService.getValidAccessToken();
    if (token == null) {
      print('❌ No valid token available for API call - session expired');
      throw AuthenticationException('Session expired');
    }

    // debugPrint("➡️ FULL URL: $baseUrl$url");
    // debugPrint("📤 Request body: ${json.encode(data ?? {})}");
    // debugPrint("Posting to full URL: $baseUrl$url");

    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data ?? {}),
    );

    // Check for authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('❌ API authentication failed - server rejected token');
      // Clear tokens and trigger session expiry handling
      await authService.handleServerAuthenticationFailure();
      throw AuthenticationException('Authentication failed');
    }

    // debugPrint("➡️ FULL URL: $baseUrl$url");
    // debugPrint("➡️ POST JSON URL: $baseUrl$url");
    // debugPrint("📤 Request body: ${json.encode(data ?? {})}");
    // debugPrint("📥 Response status: ${response.statusCode}");
    // debugPrint("📥 Response body: ${response.body}");

    if (response.body.isEmpty) return null;

    try {
      return json.decode(response.body);
    } catch (e) {
      // If not JSON, return raw body so higher-level code can handle text
      debugPrint("❌ JSON decode error (returning raw body): $e");
      return response.body;
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      // Add authentication
      final AuthService authService = AuthService();
      String? token = await authService.getValidAccessToken();
      if (token == null) {
        print('❌ No valid token available for API call - session expired');
        throw AuthenticationException('Session expired');
      }

      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add this
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      // debugPrint("🔍 GET Request URL: $url");
      // debugPrint("🔍 GET Response Status: ${response.statusCode}");
      // debugPrint("🔍 GET Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ API authentication failed - server rejected token');
        // Clear tokens and trigger session expiry handling
        await authService.handleServerAuthenticationFailure();
        throw AuthenticationException('Authentication failed');
      } else {
        throw Exception(
            'GET request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // debugPrint('❌ GET request error: $e');
      rethrow; // Re-throw to preserve the exception type
    }
  }
}
