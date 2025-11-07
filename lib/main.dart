import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/env_config.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/screens/Login/View/loginpage.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/splashscreen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initApp('prod');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NewDashboardVM(),
        ),
        ChangeNotifierProvider(create: (context) => GlobalDataManager()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> initApp(String env) async {
  EnvConfig.initialize(env);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Create a global navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    super.initState();

    // Set the navigator key in AuthService
    AuthService.setNavigatorKey(MyApp.navigatorKey);

    // Listen for app lifecycle changes
    _appLifecycleListener = AppLifecycleListener(
      onResume: _onAppResumed,
    );
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  void _onAppResumed() async {
    print('🔄 App resumed - checking authentication status');
    final authService = AuthService();
    bool isLoggedIn = await authService.isLoggedIn();

    if (!isLoggedIn) {
      print('🚪 Session expired while app was backgrounded');
      // Navigation will be handled by AuthService._handleSessionExpiry()
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey, // Add this line
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Set initial route
    );
  }
}
