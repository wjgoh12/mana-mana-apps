import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/env_config.dart';

class ApiService {
  final String baseUrl = EnvConfig.apiBaseUrl;

  Future<dynamic> post(String url, {Map<String, dynamic>? data}) async {
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
      body: json.encode(data ?? {}), // always send at least {}
    );

    if (response.body.isEmpty) return null;

    try {
      return json.decode(response.body);
    } catch (e) {
      debugPrint("❌ JSON decode error: $e");
      return null;
    }
  }

  Future<dynamic> postWithBytes(
    String url, {
    Map<String, dynamic>? data,
  }) async {
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
      body: json.encode(data ?? {}),
    );

    // debugPrint("➡️ POST BYTES URL: $baseUrl$url");
    // debugPrint("📤 Request body: ${json.encode(data ?? {})}");
    // debugPrint("📥 Response status: ${response.statusCode}");

    if (response.body.isEmpty) return null;

    if (response.body.contains("Incorrect result size")) {
      return 'Incorrect result size';
    } else {
      return response.bodyBytes;
    }
  }

  Future<dynamic> postJson(String url, {Map<String, dynamic>? data}) async {
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
      body: json.encode(data ?? {}),
    );

    debugPrint("➡️ POST JSON URL: $baseUrl$url");
    debugPrint("📤 Request body: ${json.encode(data ?? {})}");
    // debugPrint("📥 Response status: ${response.statusCode}");
    // debugPrint("📥 Response body: ${response.body}");

    if (response.body.isEmpty) return null;

    try {
      return json.decode(response.body);
    } catch (e) {
      // debugPrint("❌ JSON decode error: $e");
      return null;
    }
  }
}
