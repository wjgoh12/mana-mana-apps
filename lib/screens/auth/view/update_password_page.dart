import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mana_mana_app/config/AppAuth/native_auth_service.dart';
import 'package:mana_mana_app/screens/auth/view/login_page.dart';

class UpdatePasswordPage extends StatefulWidget {
  final String? username;
  const UpdatePasswordPage({Key? key, this.username}) : super(key: key);

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final NativeAuthService _authService = NativeAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != _newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    print('DEBUG: Updating password for username: ${widget.username}');
    setState(() => _isLoading = true);

    try {
      if (widget.username == null || widget.username!.isEmpty) {
        setState(() => _isLoading = false);
        _showError('Username is missing. Please return to login page.');
        return;
      }

      final result = await _authService.updatePasswordForUsername(
          widget.username!, newPassword);

      setState(() => _isLoading = false);
      print(
          'DEBUG: Update password result - success: ${result.success}, message: ${result.message}');

      if (result.success) {
        _showSuccessDialog();
      } else {
        _showError(result.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('DEBUG: Exception during password update: $e');
      _showError('An unexpected error occurred: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Success'),
        content: const Text(
            'Password updated successfully! Please login with your new password.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Update Error'),
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
                            fontSize: AppDimens.fontSizeBig,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF606060),
                            fontFamily: AppFonts.outfit,
                          ),
                        ),
                        Text(
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

              // Right side - Update Password Form
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isSmallScreen)
                              const CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    AssetImage('assets/images/mana2logo1.png'),
                                backgroundColor: Colors.transparent,
                              ),
                            const SizedBox(height: 30),
                            const Text(
                              "Update Password",
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeBig,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF606060),
                                fontFamily: AppFonts.outfit,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Please set your new password',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeBig,
                                color: Colors.grey[600],
                                fontFamily: AppFonts.outfit,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // New Password Field
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'New Password',
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
                              controller: _newPasswordController,
                              autofillHints: const [AutofillHints.newPassword],
                              obscureText: _obscureText,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.next,
                              // validator: _validateNewPassword,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                hintText: 'Enter new password',
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
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Confirm Password',
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
                              controller: _confirmPasswordController,
                              autofillHints: const [AutofillHints.newPassword],
                              obscureText: _obscureText,
                              validator: _validateConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleUpdatePassword(),
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                hintText: 'Confirm new password',
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

                            // Back to login
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
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
                            ),
                            const SizedBox(height: 30),

                            // Update button
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
                                onPressed:
                                    _isLoading ? null : _handleUpdatePassword,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Update Password',
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
            ],
          ),
        ),
      ),
    );
  }
}
