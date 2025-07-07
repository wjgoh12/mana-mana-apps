import 'package:flutter/material.dart';

class NewsletterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String newsletterTitle ='';
  String selectedDate = '';
  

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> subscribeToNewsletter(String email) async {
    try {
      setLoading(true);
      setErrorMessage(null);
      // TODO: Implement newsletter subscription logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setErrorMessage(e.toString());
    }
  }

  void dispose() {
    _errorMessage = null;
    _isLoading = false;
    super.dispose();
  }
}
