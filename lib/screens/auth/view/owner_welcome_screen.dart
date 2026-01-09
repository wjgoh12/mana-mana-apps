import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/auth/view_model/owner_welcome_screen_view_model.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        color: const Color(0xFF2900B7),        
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Image.asset(
                          'assets/images/cloud.png',
                          height: screenSize.height * 0.25,
                          width: screenSize.width * 0.8,
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/images/house.png',
                          height: screenSize.height * 0.25,
                          width: screenSize.width * 0.8,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFC3B9FF),                  
                          fontSize: isSmallScreen ? 32 : 40,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Open Sans'
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Text(
                        'We constantly provide information about your property and help you to gain profit as smoothly as possible.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF2900B7),
                    ),
                    onPressed: () {
                      loginAuthenticate(
                          context,
                        );
                      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> LoginPage()));
                    },
                    child: Text(
                      'Login >>>',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24 : 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC3B9FF))
                      ),
                    ),
                  ),
                SizedBox(height: screenSize.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}