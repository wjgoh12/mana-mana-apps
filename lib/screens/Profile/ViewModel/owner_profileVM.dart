import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:mana_mana_app/model/propertystate.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class OwnerProfileVM extends ChangeNotifier {
  //repo
  final RedemptionRepository _ownerBookingRepository = RedemptionRepository();
  final UserRepository _userRepository = UserRepository();

//state
  bool _isLoadingStates = false;
  bool _isLoadingLocations = false;
  String? _error;
  bool _showMyInfo = true;
  final GlobalDataManager _globalDataManager = GlobalDataManager();
  bool _isLoadingBookingHistory = false;

  //data
  List<User> _users = [];
  final UserPointBalance = [];
  List<String> _states = [];
  List<Propertystate> _locations = [];
  String _selectedState = 'Kuala Lumpur';
  List<BookingHistory> _bookingHistory = [];

  //getters
  List<BookingHistory> get bookingHistory => _bookingHistory;
  bool get showMyInfo => _showMyInfo;
  List<String> get states => _states;
  List<Propertystate> get locations => _locations;
  String get selectedState => _selectedState;
  bool get isLoadingStates => _isLoadingStates;
  bool get isLoadingLocations => _isLoadingLocations;
  String? get error => _error;
  bool get isLoadingBookingHistory => _isLoadingBookingHistory;

  // Getters that delegate to GlobalDataManager
  List<User> get users => _globalDataManager.users;
  List<OwnerPropertyList> get ownerUnits => _globalDataManager.ownerUnits;

  // Add helper methods to safely access data
  String getOwnerName() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerFullName?.toString() ?? 'No Information';
  }

  String getOwnerContact() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerContact?.toString() ?? 'No Information';
  }

  String getOwnerEmail() {
    if (users.isEmpty) return 'No Information';
    return users.first.email?.toString() ?? 'No Information';
  }

  String getOwnerAddress() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerAddress?.toString() ?? 'No Information';
  }

  String getBankInfo() {
    if (ownerUnits.isEmpty) return 'No Information';
    return ownerUnits.first.bank?.toString() ?? 'No Information';
  }

  String getAccountNumber() {
    if (ownerUnits.isEmpty) return 'No Information';
    return ownerUnits.first.accountnumber?.toString() ?? 'No Information';
  }

  Future<void> fetchData() async {
    // Use global data manager instead of making individual API calls
    await _globalDataManager.initializeData();
    _users = await _userRepository.getUsers();

    notifyListeners();
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();
    notifyListeners();
  }

  void updateShowMyInfo(bool value) {
    _showMyInfo = value;
    notifyListeners();
  }

  Future<void> fetchBookingHistory() async {
    // Get email from globalDataManager users
    final email = users.isNotEmpty ? users.first.email ?? '' : '';

    if (email.isEmpty) {
      debugPrint("⚠️ No email found, cannot fetch booking history.");
      return;
    }

    try {
      final response =
          await _ownerBookingRepository.getBookingHistory(email: email);

      _bookingHistory = response;
      debugPrint("✅ Booking history length: ${_bookingHistory.length}");

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching booking history: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPoints() async {
    final url = Uri.parse(
        'https://admin.manamanasuites.com/mobile/enqs/redemption/getUnitAvailablePoint');
    final response = await http.post(url, body: {});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<UnitAvailablePoint>> fetchUserAvailablePoints() async {
    try {
      final points = await _ownerBookingRepository.getUnitAvailablePoints();
      UserPointBalance.clear();
      UserPointBalance.addAll(points);
      notifyListeners();
      return points;
    } catch (e) {
      debugPrint("Error fetching user available points: $e");
      return [];
    }
  }

  // Future<void> loadStates() async {
  //   _isLoadingStates = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     _states = await _ownerBookingRepository.getAllStates();
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _isLoadingStates = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> fetchLocationsByState(String state) async {
    _isLoadingLocations = true;
    _error = null;
    notifyListeners();

    try {
      _locations = await _ownerBookingRepository.getAllLocationsByState(state);
      debugPrint("✅ Locations loaded: ${_locations.length}");
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error fetching locations: $e");
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

  Future<void> loadStates() async {
    _isLoadingStates = true;
    _error = null;
    notifyListeners();

    try {
      _states = await _ownerBookingRepository.getAllStates();
      if (_states.isNotEmpty) {
        _selectedState = _states.first;
        await fetchLocationsByState(_selectedState);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingStates = false;
      notifyListeners();
    }
  }
}
