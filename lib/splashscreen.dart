import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/AppAuth/native_auth_service.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/provider/version_checker.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';
import 'package:mana_mana_app/screens/Login/View/loginpage.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  final NativeAuthService _nativeAuthService = NativeAuthService();

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
    if (await versionChecker.needsUpdate()) {
      // Handle update logic here if needed
    }
    
    // Add timeout to prevent infinite loading
    try {
      await _checkAuthStatus().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      // First check if user has a valid session using native auth service
      bool hasValidSession = await _nativeAuthService.hasValidSession();
      
      if (hasValidSession) {
        // Check if tokens are still valid with the main auth service
        final authService = AuthService();
        bool isLoggedIn = await authService.isLoggedIn();
        
        if (mounted) {
          if (isLoggedIn) {
            // User is already logged in, navigate to dashboard
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const NewDashboardV3()));
          } else {
            // Session expired, show login page
            _showLoginPage();
          }
        }
      } else {
        // No valid session, show login page
        if (mounted) {
          _showLoginPage();
        }
      }
    } catch (e) {
      if (mounted) {
        // If error checking auth, show login page
        _showLoginPage();
      }
    }
  }

  void _showLoginPage() {
    setState(() {
      _isLoading = false;
    });
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginScreenBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.transparent,
                backgroundImage: const AssetImage('assets/images/mana2logo1.png'),
              ),
              const SizedBox(height: 40),
              // Title text
              const Text(
                'Simple, Timeless',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF606060),
                  fontFamily: 'Outfit',
                ),
              ),
              const Text(
                'Assets Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF606060),
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 40),
              // Loading indicator
              if (_isLoading)
                const CircularProgressIndicator(
                  color: Color(0xFF606060),
                ),
            ],
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
