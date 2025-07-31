import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/provider/version_checker.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    //FULLSCREEN
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
            title: const Text('Update Available'),
            content: const Text(
                'A new version is available. Please update to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  versionChecker.launchUpdate();
                },
                child: const Text('Update Now'),
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
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const NewDashboardV3()));
          } else {}
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
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const NewDashboardV3()));
          } else {
            // Show error message
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
          title: const Text('Update Available'),
          content: const Text(
              'A new version is available. Please update to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                versionChecker.launchUpdate();
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    }
  }
}
