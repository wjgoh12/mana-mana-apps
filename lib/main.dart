import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/env_config.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/splashscreen.dart';
import 'package:provider/provider.dart';

void main() {
  // Initialize the app
  WidgetsFlutterBinding.ensureInitialized();
  initApp('prod');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NewDashboardVM()..fetchData(),
        ),
        ChangeNotifierProvider(
          create: (context) => GlobalDataManager(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> initApp(String env) async {
  EnvConfig.initialize(env);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splashscreen(), // Set initial route
    );
  }
}
