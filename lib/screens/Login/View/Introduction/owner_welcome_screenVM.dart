import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/screens/Dashboard/View/dashboard.dart';

Future<void> loginAuthenticate(BuildContext context) async {
  final authService = AuthService();
  bool success = await authService.authenticate();
    if (success) {
      // Navigate to home page or show success message
      print('Login successful');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> NewDashboardPage()));
    } else {
      // Show error message
      print('Login failed');
    }
}