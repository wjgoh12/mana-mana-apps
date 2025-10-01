import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/provider/version_checker.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _needsLogin = false;

  @override
  void initState() {
    super.initState();

    //FULLSCREEN
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initialize();
  }

  void _initialize() async {
    // Clear any cached data from previous sessions on app restart
    final globalDataManager = GlobalDataManager();
    globalDataManager.clearAllData();

    final versionChecker = VersionChecker();
    if (await versionChecker.needsUpdate())
      //{
      //   if (mounted) {
      //     showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (context) => AlertDialog(
      //         title: const Text('Update Available'),
      //         content: const Text(
      //             'A new version is available. Please update to continue.'),
      //         actions: [
      //           TextButton(
      //             onPressed: () {
      //               versionChecker.launchUpdate();
      //             },
      //             child: const Text('Update Now'),
      //           ),
      //         ],
      //       ),
      //     );
      //   }
      // } else
      await _checkAuthStatus();
    // {
    //   // Proceed with login only if no update is needed
    //   Future.delayed(const Duration(seconds: 2), () async {
    //     final authService = AuthService();
    //     bool success = await authService.authenticate();
    //     if (mounted) {
    //       if (success) {
    //         Navigator.of(context).pushReplacement(
    //             MaterialPageRoute(builder: (_) => const NewDashboardV3()));
    //       } else {}
    //     }
    //   });
    // }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authService = AuthService();
      bool isLoggedIn = await authService.isLoggedIn();

      if (mounted) {
        if (isLoggedIn) {
          // User is already logged in, navigate to dashboard
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NewDashboardV3()));
        } else {
          // User needs to login - automatically trigger login
          await _handleLogin();
        }
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      if (mounted) {
        // If error checking auth, try to login
        await _handleLogin();
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _needsLogin = false;
    });

    try {
      final authService = AuthService();
      bool success = await authService.authenticate();

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NewDashboardV3()));
        } else {
          // Login failed or cancelled, show retry option
          setState(() {
            _isLoading = false;
            _needsLogin = true;
          });

          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Login failed or cancelled. Tap to retry.'),
          //     backgroundColor: Colors.orange,
          //   ),
          // );
        }
      }
    } catch (e) {
      print('❌ Login error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _needsLogin = true;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Login error. Tap to retry.'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _needsLogin && !_isLoading ? _handleLogin : null,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splashscreen.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _needsLogin
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Tap to Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
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
