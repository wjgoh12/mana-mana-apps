import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mana_mana_app/config/AppAuth/native_auth_service.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/dashboard/view/dashboard_view.dart';
import 'package:mana_mana_app/screens/auth/view/forgot_password_page.dart';
import 'package:mana_mana_app/screens/auth/view/update_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _isLoading = false;
  bool _checkingSession = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NativeAuthService _authService = NativeAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkSession();
      await _loadSavedCredentials();
    });
  }

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

  Future<void> _checkSession() async {
    setState(() => _checkingSession = true);

    final hasSession = await _authService.hasValidSession();

    if (hasSession && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NewDashboardV3()),
      );
      return;
    }

    if (mounted) setState(() => _checkingSession = false);
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await storage.read(key: 'saved_email');
    final savedPassword = await storage.read(key: 'saved_password');

    if (savedEmail != null) _usernameController.text = savedEmail;
    if (savedPassword != null) _passwordController.text = savedPassword;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      print('DEBUG: Attempting authentication for: $username');
      final result = await _authService.authenticate(username, password);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          try {
            TextInput.finishAutofillContext(shouldSave: true);
          } catch (_) {}

          await Future.delayed(const Duration(milliseconds: 500));

          FocusScope.of(context).unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');

          try {
            TextInput.finishAutofillContext(shouldSave: true);
          } catch (_) {}

          if (!mounted) return;

          print('🧹 Clearing cached data before navigating to dashboard');
          GlobalDataManager().clearAllData();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NewDashboardV3()),
          );
        } else {
          TextInput.finishAutofillContext(shouldSave: false);

          if (result.message.toLowerCase().contains('not fully set up') ||
              result.message
                  .toLowerCase()
                  .contains('account is not fully setup')) {
            print(
                'DEBUG: Account not fully set up, redirecting to UpdatePasswordPage');
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => UpdatePasswordPage(username: username),
              ),
            );
          } else if (result.message
              .toLowerCase()
              .contains('invalid user credentials')) {
            print(
                'DEBUG: Invalid credentials - checking if first-time login...');
            final isFirst = await _authService.isFirstLogin(username);
            print('DEBUG: isFirstLogin result: $isFirst');

            if (isFirst) {
              print(
                  'DEBUG: First-time login detected, redirecting to UpdatePasswordPage');
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => UpdatePasswordPage(username: username),
                ),
              );
            } else {
              _showErrorDialog('Invalid username or password');
            }
          } else {
            // Other login errors
            _showErrorDialog(result.message);
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Login Error: $e');
      debugPrint('❌ Stack Trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        TextInput.finishAutofillContext(shouldSave: false);
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
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
                                fontSize: AppDimens.fontSizeBig,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGrey,
                                fontFamily: AppFonts.outfit,
                              ),
                            ),
                            Text(
                              'Assets Management',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeBig,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGrey,
                                fontFamily: AppFonts.outfit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                      fontSize: AppDimens.fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGrey,
                                      fontFamily: AppFonts.outfit,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Please login to continue',
                                    style: TextStyle(
                                      fontSize: AppDimens.fontSizeBig,
                                      color: Colors.grey[600],
                                      fontFamily: AppFonts.outfit,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'E-mail',
                                      style: TextStyle(
                                        fontSize: AppDimens.fontSizeBig,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                        fontFamily: AppFonts.outfit,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AutofillGroup(
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _usernameController,
                                          // CRITICAL: These hints tell Huawei this is username/email
                                          autofillHints: const [
                                            AutofillHints.username,
                                            AutofillHints.email,
                                          ],
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          validator: _validateEmail,
                                          // CRITICAL: Enable autofill
                                          enableSuggestions: true,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                            hintText: 'youremail@domain.com',
                                            hintStyle: TextStyle(
                                                color: Colors.grey[400]),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.grey[300]!),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Password Field
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Password',
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
                                          controller: _passwordController,
                                          autofillHints: const [
                                            AutofillHints.password
                                          ],
                                          obscureText: _obscureText,
                                          validator: _validatePassword,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) =>
                                              _handleLogin(),
                                          // CRITICAL: Enable autofill
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                            hintText: 'Password',
                                            hintStyle: TextStyle(
                                                color: Colors.grey[400]),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.grey[300]!),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureText
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscureText = !_obscureText),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 15),

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
                                          fontSize: AppDimens.fontSizeSmall,
                                          color: AppColors.primaryGrey,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: AppFonts.outfit,
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
                                        backgroundColor: AppColors.primaryGrey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed:
                                          _isLoading ? null : _handleLogin,
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: AppDimens.fontSizeBig,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontFamily: AppFonts.outfit,
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
          if (_checkingSession)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
