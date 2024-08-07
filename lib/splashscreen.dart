import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/screens/Dashboard/View/dashboard.dart';
import 'package:mana_mana_app/screens/Login/View/Introduction/owner_welcome_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen> with SingleTickerProviderStateMixin{
  
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final authService = AuthService();
      bool success = await authService.authenticate();
      if (success) {
        // Navigate to home page or show success message
        print('Login successful');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NewDashboardPage()));
      } else {
        // Show error message
        print('Login failed');
      }
    });
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          final authService = AuthService();
          bool success = await authService.authenticate();
          if (success) {
            // Navigate to home page or show success message
            print('Login successful');
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NewDashboardPage()));
          } else {
            // Show error message
            print('Login failed');
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splashscreen.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}