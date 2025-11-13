import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mana_mana_app/config/AppAuth/native_auth_service.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';
import 'package:mana_mana_app/screens/Login/View/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NativeAuthService _authService = NativeAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> saveLogin(String email, String token) async {
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'token', value: token);
  }

  Future<void> autoLogin() async {
    final token = await storage.read(key: 'token');
    final email = await storage.read(key: 'email');
    if (token != null) {
      // Automatically log user in
      print('Auto-login as $email');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final result = await _authService.authenticate(username, password);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          FocusScope.of(context).unfocus();
          // Small additional hide to ensure keyboard is dismissed on some devices
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          TextInput.finishAutofillContext();
          // Wait for the platform UI to appear (widely-compatible delay)
          await Future.delayed(const Duration(milliseconds: 1000));

          // Navigate to dashboard
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NewDashboardV3()),
          );
        } else {
          _showErrorDialog(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
          child: Row(
            children: [
              if (!isSmallScreen)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              AssetImage('assets/images/mana2logo1.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Simple, Timeless',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF606060),
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Text(
                          'Assets Management',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF606060),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Right side - Login Form
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isSmallScreen ? screenSize.width * 0.08 : 60,
                      ),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (isSmallScreen)
                                const CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage(
                                      'assets/images/mana2logo1.png'),
                                  backgroundColor: Colors.transparent,
                                ),
                              const SizedBox(height: 30),
                              const Text(
                                "Owner's Portal",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF606060),
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Please login to continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Email
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'E-mail',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                                decoration: InputDecoration(
                                  hintText: 'youremail@domain.com',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                autofillHints: const [AutofillHints.password],
                                obscureText: _obscureText,
                                validator: _validatePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureText = !_obscureText),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF606060),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF606060),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _handleLogin,
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
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
