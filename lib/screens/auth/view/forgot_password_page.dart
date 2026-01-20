import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/native_auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final NativeAuthService _authService = NativeAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.requestPasswordReset(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.success) {
          // Show success dialog and navigate back
          _showSuccessDialog(result.message);
        } else {
          // Show error dialog
          _showErrorDialog(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Reset'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginScreenBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button at top-left
              // Positioned(
              //   top: 10,
              //   left: 10,
              //   child: IconButton(
              //     icon: const Icon(Icons.arrow_back),
              //     color: AppColors.primaryGrey,
              //     iconSize: 28,
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ),

              // Main content
              Row(
                children: [
                  // Left side - Splash/Branding (only on larger screens)
                  if (!isSmallScreen)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.transparent,
                              backgroundImage: const AssetImage(
                                  'assets/images/mana2logo1.png'),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              'Simple, Timeless',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeBig,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF606060),
                                fontFamily: AppFonts.outfit,
                              ),
                            ),
                            const Text(
                              'Assets Management',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeBig,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF606060),
                                fontFamily: AppFonts.outfit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Right side - Forgot Password Form
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isSmallScreen ? screenSize.width * 0.08 : 60,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Logo for small screens
                                if (isSmallScreen) ...[
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: const AssetImage(
                                        'assets/images/mana2logo1.png'),
                                  ),
                                  const SizedBox(height: 30),
                                ],

                                // Title
                                const Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeBig,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF606060),
                                    fontFamily: AppFonts.outfit,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Reset your password',
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeBig,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.outfit,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Enter your email address below and we'll send you instructions to reset your password directly to your email.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeSmall,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                    fontFamily: AppFonts.outfit,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Email Field
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Email Address',
                                    style: TextStyle(
                                      fontSize: AppDimens.fontSizeBig,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                      fontFamily: AppFonts.outfit,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  decoration: InputDecoration(
                                    hintText: 'emailemail@domain.com',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF606060), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Send Reset Email Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : _handleForgotPassword,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Send Reset Email',
                                            style: TextStyle(
                                              fontSize: AppDimens.fontSizeBig,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontFamily: AppFonts.outfit,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Back to Login link
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      fontSize: AppDimens.fontSizeSmall,
                                      color: Color(0xFF606060),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFonts.outfit,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
