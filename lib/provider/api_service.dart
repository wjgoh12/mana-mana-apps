import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/env_config.dart';

class ApiService {
  final String baseUrl = EnvConfig.api_baseUrl;

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
      },
      body: json.encode(data),
    );

    return json.decode(response.body);
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
  
}
