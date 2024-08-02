import 'package:flutter/material.dart';
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
    Future.delayed(const Duration(seconds: 2),(){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const OnboardingScreen()));
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const NewDashboardPage()));
    });
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splashscreen.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}