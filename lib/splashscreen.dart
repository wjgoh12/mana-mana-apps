import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/AppAuth/native_auth_service.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/provider/version_checker.dart';
import 'package:mana_mana_app/screens/dashboard/view/dashboard_view.dart';
import 'package:mana_mana_app/screens/auth/view/login_page.dart';

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
    _initialize();
  }

  void _initialize() async {
    // ✅ IMPORTANT: DON'T clear data here - we need it to check auth!
    // Only clear runtime cache, not stored credentials
    final globalDataManager = GlobalDataManager();
    globalDataManager.clearRuntimeCache(); // Use this instead of clearAllData()

    final versionChecker = VersionChecker();
    if (await versionChecker.needsUpdate()) {
      // Handle update logic here if needed
    }

    try {
      await _checkAuthStatus().timeout(
        const Duration(seconds: 10), // Reduced timeout
        onTimeout: () {
          print('⚠️ Auth check timeout - showing login page');
          if (mounted) {
            _showLoginPage();
          }
        },
      );
    } catch (e) {
      print('❌ Error during auth check: $e');
      if (mounted) {
        _showLoginPage();
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('🔍 Checking authentication status...');

      // First check if user has a valid session using native auth service
      bool hasValidSession = await _nativeAuthService.hasValidSession();
      print('📱 Native session valid: $hasValidSession');

      if (hasValidSession) {
        // Check if tokens are still valid with the main auth service
        final authService = AuthService();
        bool isLoggedIn = await authService.isLoggedIn();
        print('🔐 Auth service logged in: $isLoggedIn');

        if (mounted) {
          if (isLoggedIn) {
            print('✅ User authenticated - navigating to dashboard');
            // User is already logged in, navigate to dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NewDashboardV3()),
            );
          } else {
            print('⚠️ Session expired - showing login page');
            // Session expired, show login page
            _showLoginPage();
          }
        }
      } else {
        print('❌ No valid session - showing login page');
        // No valid session, show login page
        if (mounted) {
          _showLoginPage();
        }
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          // Gradient background that mimics the cloudy effect
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F8F8), // Light gray at top
              Color(0xFFE8E8E8), // Medium gray
              Color(0xFFD0D0D0), // Darker gray at bottom (cloudy effect)
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      AssetImage('assets/images/mana2logo1.png'),
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
      ),
    );
  }
}
