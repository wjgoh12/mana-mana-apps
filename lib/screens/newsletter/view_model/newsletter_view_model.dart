import 'package:flutter/material.dart';

class NewsletterVM extends ChangeNotifier {
  List <Map<String, dynamic>> _newsletter = [];
  List<Map<String, dynamic>> get newsletter => _newsletter;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  
  String newsletterTitle ='';
  String selectedDate = '';
  String newsletterDescription = '';
  String newsletterContent = '';


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
      
      await Future.delayed(const Duration(seconds: 2)); 
      // Simulate API call
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