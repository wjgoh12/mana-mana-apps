import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/provider/version_checker.dart';
import 'package:mana_mana_app/screens/Dashboard/View/dashboard.dart';
import 'package:mana_mana_app/screens/Login/View/Introduction/owner_welcome_screen.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/new_dashboard.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  bool _checkedForUpdates = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    final versionChecker = VersionChecker();
    if (await versionChecker.needsUpdate()) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Update Available'),
            content:
                Text('A new version is available. Please update to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  versionChecker.launchUpdate();
                },
                child: Text('Update Now'),
              ),
            ],
          ),
        );
      }
    } else {
      // Proceed with login only if no update is needed
      Future.delayed(const Duration(seconds: 2), () async {
        final authService = AuthService();
        bool success = await authService.authenticate();
        if (mounted) {
          if (success) {
            print('Login successful');
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => NewDashboard()));
          } else {
            print('Login failed');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          final authService = AuthService();
          bool success = await authService.authenticate();
          if (success) {
            // Navigate to home page or show success message
            print('Login successful');
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => NewDashboard()));
          } else {
            // Show error message
            print('Login failed');
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splashscreen.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  void checkForUpdates() async {
    final versionChecker = VersionChecker();
    if (await versionChecker.needsUpdate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Update Available'),
          content:
              Text('A new version is available. Please update to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                versionChecker.launchUpdate();
              },
              child: Text('Update Now'),
            ),
          ],
        ),
      );
    }
  }
}
