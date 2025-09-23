import 'package:flutter/foundation.dart';

class PropertyStateCache extends ChangeNotifier {
  static final PropertyStateCache _instance = PropertyStateCache._internal();
  factory PropertyStateCache() => _instance;
  PropertyStateCache._internal();

  final Map<String, List<dynamic>> _locationsByState = {};
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  bool get isLoading => _isLoading;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Cache expiry time - 30 minutes
  static const Duration cacheExpiry = Duration(minutes: 30);

  bool shouldRefresh() {
    if (_lastFetchTime == null) return true;
    final now = DateTime.now();
    return now.difference(_lastFetchTime!) > cacheExpiry;
  }

  void cacheLocationsForState(String state, List<dynamic> locations) {
    _locationsByState[state] = locations;
    _lastFetchTime = DateTime.now();
    notifyListeners();
  }

  List<dynamic>? getLocationsForState(String state) {
    return _locationsByState[state];
  }

  void clearCache() {
    _locationsByState.clear();
    _lastFetchTime = null;
    notifyListeners();
  }
}
