import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
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
  bool _isLoadingAvailablePoints = false;
  bool _isLoadingBlockedDates = false;

  //data
  List<User> _users = [];
  final UserPointBalance = [];
  List<String> _states = [];
  List<Propertystate> _locationsInState = [];
  String _selectedState = '';
  List<BookingHistory> _bookingHistory = [];
  List<UnitAvailablePoint> _unitAvailablePoints = [];
  List<CalendarBlockedDate> _blockedDates = [];

  //getters
  List<BookingHistory> get bookingHistory => _bookingHistory;
  List<UnitAvailablePoint> get unitAvailablePoints => _unitAvailablePoints;
  bool get showMyInfo => _showMyInfo;
  List<String> get states => _states;
  List<Propertystate> get locations => _locationsInState;
  String get selectedState => _selectedState;
  bool get isLoadingStates => _isLoadingStates;
  bool get isLoadingLocations => _isLoadingLocations;
  String? get error => _error;
  bool get isLoadingBookingHistory => _isLoadingBookingHistory;
  bool get isLoadingAvailablePoints => _isLoadingAvailablePoints;
  List<CalendarBlockedDate> get blockedDates => _blockedDates;
  bool get isLoadingBlockedDates => _isLoadingBlockedDates;

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
    final email = users.isNotEmpty ? users.first.email ?? '' : '';

    if (email.isEmpty) {
      debugPrint("⚠️ No email found, cannot fetch booking history.");
      return;
    }

    try {
      _isLoadingBookingHistory = true;
      notifyListeners();
      final response = await _ownerBookingRepository.getBookingHistory(
        email: email,
      );

      _bookingHistory = response;
      debugPrint("✅ Booking history length: ${_bookingHistory.length}");
    } catch (e) {
      debugPrint('❌ Error fetching booking history: $e');
    } finally {
      _isLoadingBookingHistory = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserAvailablePoints() async {
    final email = users.isNotEmpty ? users.first.email ?? '' : '';

    if (email.isEmpty) {
      debugPrint("⚠️ No email found, cannot fetch available points.");
      return;
    }

    try {
      _isLoadingAvailablePoints = true;
      notifyListeners();
      final response = await _ownerBookingRepository.getUnitAvailablePoints(
        email: email,
      );

      _unitAvailablePoints = response;
      debugPrint("✅ Available points length: ${_unitAvailablePoints.length}");
    } catch (e) {
      debugPrint('❌ Error fetching available points: $e');
    } finally {
      // ❌ BUG: wrong flag here
      _isLoadingBookingHistory = false;

      // ✅ Correct it:
      _isLoadingAvailablePoints = false;

      notifyListeners();
    }
  }

  Future<void> fetchLocationsByState(String state) async {
    _isLoadingLocations = true;
    _error = null;
    notifyListeners();

    try {
      _locationsInState =
          await _ownerBookingRepository.getAllLocationsByState(state);
      debugPrint("✅ Locations loaded: ${_locationsInState.length}");
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
      _states = await _ownerBookingRepository.getAvailableStates();
      // Don’t auto-select state here. Let user pick from dropdown.
      _selectedState = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingStates = false;
      notifyListeners();
    }
  }

  Future<void> fetchRedemptionBalancePoints({
    required String location,
    required String unitNo,
  }) async {
    if (location.isEmpty || unitNo.isEmpty) {
      debugPrint(
          "⚠️ Location or Unit No is empty, cannot fetch redemption balance points.");
      return;
    }

    try {
      _isLoadingAvailablePoints = true;
      notifyListeners();

      final response = await _ownerBookingRepository.getRedemptionBalancePoints(
        location: location,
        unitNo: unitNo,
      );

      UserPointBalance.clear();
      UserPointBalance.addAll(response);

      debugPrint(
          "✅ Redemption balance points length: ${UserPointBalance.length}");
    } catch (e) {
      debugPrint('❌ Error fetching redemption balance points: $e');
    } finally {
      _isLoadingAvailablePoints = false;
      notifyListeners();
    }
  }

  Future<void> fetchBlockedDates({
    required String location,
    required String state,
  }) async {
    _isLoadingBlockedDates = true;
    notifyListeners();

    try {
      final res = await _ownerBookingRepository.getCalendarBlockedDates(
        location: location,
        startDate: DateTime.now().toIso8601String(),
        endDate:
            DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      );

      if (res is! List) {
        throw Exception('Unexpected API response for blocked dates');
      }

      final dates = res.map((e) => CalendarBlockedDate.fromJson(e)).toList();

      _blockedDates = _ownerBookingRepository.filterBlockedDatesForState(
        dates,
        state,
      );

      debugPrint("✅ Blocked dates loaded: ${_blockedDates.length}");
    } catch (e) {
      debugPrint("❌ Failed to fetch blocked dates: $e");
      _blockedDates = [];
    } finally {
      _isLoadingBlockedDates = false;
      notifyListeners();
    }
  }
}
