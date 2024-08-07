import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/config/env_config.dart';

class ApiService {
  final String baseUrl = EnvConfig.api_baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<dynamic> post(String url, {Map<String, dynamic>? data}) async {
    String? token = await _secureStorage.read(key: 'access_token');
    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    return json.decode(response.body);
  }

  Future<dynamic> postWithBytes(String url, {Map<String, dynamic>? data}) async {
    String? token = await _secureStorage.read(key: 'access_token');
    final response = await http.post(
      Uri.parse('$baseUrl$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        
      },
      body: json.encode(data),
    );

    return response.bodyBytes;
  }
}
