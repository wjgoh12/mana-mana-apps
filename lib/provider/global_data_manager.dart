import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/occupancy_rate.dart';
import 'package:mana_mana_app/model/propertyState.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GlobalDataManager extends ChangeNotifier {
  static final GlobalDataManager _instance = GlobalDataManager._internal();
  factory GlobalDataManager() => _instance;
  GlobalDataManager._internal();

  // Repositories
  final UserRepository _userRepository = UserRepository();
  final PropertyListRepository _propertyRepository = PropertyListRepository();
  final RedemptionRepository _redemptionRepository = RedemptionRepository();

  // Data state
  bool _isInitialized = false;
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  // Core data
  List<User> _users = [];
  List<OwnerPropertyList> _ownerUnits = [];
  List<SingleUnitByMonth> _unitByMonth = [];
  List<Map<String, dynamic>> _revenueDashboard = [];
  List<Map<String, dynamic>> _totalByMonth = [];
  List<Map<String, dynamic>> _locationByMonth = [];
  List<Map<String, dynamic>> _propertyContractType = [];
  Map<String, dynamic> _propertyOccupancy = {};
  List<String> _availableStates = [];
  Map<String, List<PropertyState>> _locationsByState = {};
  List<OccupancyRate> _occupancyRateHistory = [];
  // Keep snapshot of admin/original state before impersonation
  List<User> _originalUsersBackup = [];
  List<OwnerPropertyList> _originalOwnerUnits = [];
  bool _isImpersonating = false;

  // Variable to store the original user before impersonation
  User? _originalUser;

  // Impersonation state: when set, user data will be fetched by this email
  String? _impersonatedEmail;

  // Add new state properties
  bool _isLoadingStates = false;
  bool _isLoadingLocations = false;
  String? _selectedState;

  // Add cache for filtered locations
  Map<String, List<PropertyState>> _filteredLocationCache = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  List<User> get users => List.unmodifiable(_users);
  List<OwnerPropertyList> get ownerUnits => List.unmodifiable(_ownerUnits);
  List<SingleUnitByMonth> get unitByMonth => List.unmodifiable(_unitByMonth);
  List<Map<String, dynamic>> get revenueDashboard =>
      List.unmodifiable(_revenueDashboard);
  List<Map<String, dynamic>> get totalByMonth =>
      List.unmodifiable(_totalByMonth);
  List<Map<String, dynamic>> get locationByMonth =>
      List.unmodifiable(_locationByMonth);
  List<Map<String, dynamic>> get propertyContractType =>
      List.unmodifiable(_propertyContractType);
  Map<String, dynamic> get propertyOccupancy =>
      Map.unmodifiable(_propertyOccupancy);
  List<OccupancyRate> get occupancyRateHistory =>
      List.unmodifiable(_occupancyRateHistory);

  bool get isLoadingStates => _isLoadingStates;
  bool get isLoadingLocations => _isLoadingLocations;
  String? get selectedState => _selectedState;
  String? get impersonatedEmail => _impersonatedEmail;

  // Method to clear location loading flag after preload completes
  void clearLocationLoadingFlag() {
    _isLoadingLocations = false;
    notifyListeners();
  }

  String get userNameAccount =>
      _users.isNotEmpty ? _users.first.ownerFullName ?? '-' : '-';

  String get revenueLatestYear => _revenueDashboard.isNotEmpty
      ? _revenueDashboard
          .map((item) => item['year'] as int)
          .reduce((max, current) => max > current ? max : current)
          .toString()
      : DateTime.now().year.toString();
  List<String> get availableStates => List.unmodifiable(_availableStates);

  Map<String, List<PropertyState>> get locationsByState =>
      Map.unmodifiable(_locationsByState);

  List<PropertyState> getLocationsForState(String state) {
    return _locationsByState[state] ?? [];
  }

  // Add this method to set selected state

  Future<void> updateSelectedState(String state) async {
    _selectedState = state;
    notifyListeners();
  }

  // Initialize all data
  Future<void> initializeData({bool forceRefresh = false}) async {
    // Don't reload if already initialized and not forced
    if (_isInitialized && !forceRefresh) {
      return;
    }

    // Don't reload if already loading
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch all core data
      await _fetchAllData();

      // Don't fetch states/locations during initialization
      // They will be loaded when user navigates to location selection screen

      _isInitialized = true;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Error initializing global data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAllData() async {
    debugPrint('🔄 _fetchAllData start; impersonatedEmail=$_impersonatedEmail');

    // STEP 1️⃣ — Handle User Data
    if (_impersonatedEmail != null && _impersonatedEmail!.isNotEmpty) {
      // Try to fetch the real user profile for the impersonated email.
      // If backend returns a matching user, use it. Otherwise fall back to
      // the normal (admin) user to avoid mixing data.
      try {
        final switched =
            await _userRepository.getSwitchedUser(_impersonatedEmail!);
        if (switched.isNotEmpty &&
            (switched.first.email ?? '').toLowerCase() ==
                _impersonatedEmail!.toLowerCase()) {
          _users = [switched.first];
          debugPrint(
              '✅ Impersonation: backend returned full profile for $_impersonatedEmail');
        } else {
          debugPrint(
              '⚠️ Backend did not return impersonated profile for $_impersonatedEmail; falling back to admin user.');
          _users = await _userRepository.getUsers();
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching impersonated user: $e');
        _users = await _userRepository.getUsers();
      }
    } else {
      // No impersonation → normal flow
      _users = await _userRepository.getUsers();
    }

    debugPrint(
        '👤 Active user: ${_users.isNotEmpty ? _users.first.email : 'none'}');

    // STEP 2️⃣ — Fetch everything else using that impersonated email
    final targetEmail =
        _impersonatedEmail?.isNotEmpty == true ? _impersonatedEmail : null;

    _ownerUnits = await _propertyRepository.getOwnerUnit(email: targetEmail);
    debugPrint('🏢 ownerUnits count=${_ownerUnits.length}');

    _unitByMonth = await _propertyRepository.getUnitByMonth();
    _revenueDashboard = await _propertyRepository.revenueByYear();
    _totalByMonth = await _propertyRepository.totalByMonth();
    _locationByMonth = await _propertyRepository.locationByMonth();

    if (targetEmail != null) {
      _users = await _userRepository.getSwitchedUser(targetEmail);
    } else {
      _users = await _userRepository.getUsers();
    }

    try {
      final email = targetEmail ?? '';
      final contractResponse =
          await _propertyRepository.getPropertyContractType(email: email);
      _propertyContractType = List<Map<String, dynamic>>.from(contractResponse);
    } catch (e) {
      print('Error fetching property contract type: $e');
      _propertyContractType = [];
    }

    await _fetchPropertyOccupancy();
    await _fetchInitialOccupancyHistory();

    // Add owners info to locationByMonth
    for (var location in _locationByMonth) {
      List<Map<String, dynamic>> ownersForLocation = _propertyContractType
          .where((p) => p['location'] == location['location'])
          .toList();

      location['owners'] = ownersForLocation.map((p) {
        return {
          'ownerName': p['ownerName'],
          'coOwnerName': p['coOwnerName'],
          'unitNo': p['unitNo'],
          'contractType': p['contractType'],
          'endDate': p['endDate'],
          'startDate': p['startDate'],
        };
      }).toList();
    }

    debugPrint('✅ _fetchAllData finished for $targetEmail');
  }

  Future<void> _fetchPropertyOccupancy() async {
    try {
      Set<String> locations = _propertyContractType
          .map((property) => property['location'] as String)
          .toSet();

      // Fetch all occupancy data in parallel instead of sequentially
      final occupancyResults = await Future.wait(
        locations.map((location) async {
          try {
            final unitForLocation = _propertyContractType
                .firstWhere((property) => property['location'] == location);

            final occupancy = await _propertyRepository.getPropertyOccupancy(
              location: location,
              unitNo: unitForLocation['unitNo'],
            );

            if (occupancy.containsKey('amount')) {
              return MapEntry(location, occupancy);
            }
          } catch (e) {
            print('Error fetching occupancy for $location: $e');
          }
          return null;
        }),
      );

      // Convert results to map, filtering out nulls
      _propertyOccupancy = Map.fromEntries(
        occupancyResults.whereType<MapEntry<String, dynamic>>(),
      );
    } catch (e) {
      print('Error loading property occupancy: $e');
      _propertyOccupancy = {};
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await initializeData(forceRefresh: true);
  }

  /// Create a lightweight snapshot of current key data so impersonation can be reverted.
  Map<String, dynamic> createSnapshot() {
    return {
      'users': _users
          .map((u) => {
                'email': u.email,
                'firstName': u.firstName,
                'lastName': u.lastName,
                'token': u.token,
                'role': u.role,
                'ownerEmail': u.ownerEmail,
                'ownerFullName': u.ownerFullName,
                'ownerContact': u.ownerContact,
                'ownerAddress': u.ownerAddress,
              })
          .toList(),
      'impersonatedEmail': _impersonatedEmail,
      // Note: ownerUnits and other large structures are intentionally omitted
      // to keep the snapshot small. They will be re-fetched when restoring.
    };
  }

  /// Restore a snapshot created by [createSnapshot]. This will overwrite in-memory users and impersonation flag.
  void restoreSnapshot(Map<String, dynamic> snapshot) {
    try {
      final usersList = snapshot['users'] as List<dynamic>? ?? [];
      _users = usersList.map((m) {
        final mm = Map<String, dynamic>.from(m as Map);
        return User.fromJson(mm);
      }).toList();

      _impersonatedEmail = snapshot['impersonatedEmail'] as String?;
      // Re-fetch other cached data when needed by callers
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to restore snapshot: $e');
    }
  }

  /// Apply an impersonated user object so the UI shows the impersonated account immediately.
  void applyImpersonatedUser(User u) {
    _users = [u];
    _impersonatedEmail = u.email;
    // Clear caches that are specific to a user so re-fetch will use the impersonated email
    resetAllData();
    notifyListeners();
  }

  // Helper methods for accessing specific data
  List<Map<String, dynamic>> getMonthlyProfitOwner() {
    return _totalByMonth
        .where((unit) => unit['transcode'] == "NOPROF")
        .toList();
  }

  List<Map<String, dynamic>> getMonthlyBlcOwner() {
    return _totalByMonth.where((unit) => unit['transcode'] == "OWNBAL").toList()
      ..sort((a, b) {
        int yearComparison = a['year'].compareTo(b['year']);
        return yearComparison != 0
            ? yearComparison
            : a['month'].compareTo(b['month']);
      });
  }

  Future<double> getOverallBalance() async {
    return _revenueDashboard.isNotEmpty
        ? _revenueDashboard
            .where((item) =>
                item["transcode"] == "OWNBAL" &&
                item["year"] == int.parse(revenueLatestYear))
            .map((item) => item["total"])
            .first
        : 0.0;
  }

  Future<double> getOverallProfit() async {
    return _revenueDashboard.isNotEmpty
        ? _revenueDashboard
            .where((item) =>
                item["transcode"] == "NOPROF" &&
                item["year"] == int.parse(revenueLatestYear))
            .map((item) => item["total"])
            .first
        : 0.0;
  }

  int getUnitLatestMonth() {
    try {
      return _locationByMonth
          .map((unit) => {'month': unit['month'], 'year': unit['year']})
          .reduce((max, current) => max['year'] > current['year']
              ? max
              : max['year'] == current['year'] &&
                      max['month'] > current['month']
                  ? max
                  : current)['month'];
    } catch (e) {
      return 0;
    }
  }

  String getContractType(String location) {
    try {
      final contract = _propertyContractType
          .firstWhere((contract) => contract['location'] == location);
      return contract['contractType'] ?? '';
    } catch (e) {
      return '';
    }
  }

  // Property detail specific helpers
  List<String> getTypeItemsForProperty(String property) {
    final List<String> builtTypeItems = _ownerUnits
        .where((types) => types.location == property)
        .map((types) => '${types.type} (${types.unitno})')
        .toList();

    final Set<String> seen = <String>{};
    return builtTypeItems.where((e) => seen.add(e)).toList();
  }

  List<String> getYearItemsForUnit(String unitNo) {
    return _unitByMonth
        .where((unit) => unit.sunitno == unitNo)
        .map((unit) => unit.iyear?.toString() ?? '')
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
  }

  List<String> getMonthItemsForUnitAndYear(String unitNo, String year) {
    return _unitByMonth
        .where(
            (unit) => unit.sunitno == unitNo && unit.iyear?.toString() == year)
        .map((unit) => unit.imonth?.toString() ?? '')
        .where((month) => month.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
  }

  SingleUnitByMonth? getSelectedUnitData(
      String unitNo, String transCode, int? year, int? month) {
    try {
      return _unitByMonth.firstWhere((unit) =>
          unit.sunitno == unitNo &&
          unit.stranscode == transCode &&
          (year == null || unit.iyear == year) &&
          (month == null || unit.imonth == month));
    } catch (e) {
      return null;
    }
  }

  // In GlobalDataManager
  List<Map<String, dynamic>> getAvailableLocationsWithRooms() {
    return _locationByMonth.where((location) {
      final owners = location['owners'] as List<dynamic>? ?? [];
      // ✅ Check if this location has any room/unit (you decide what condition = room type available)
      return owners.isNotEmpty;
    }).toList();
  }

  // Modify the existing fetchRedemptionStatesAndLocations method
  Future<void> fetchRedemptionStatesAndLocations() async {
    // ✅ Return early if already loaded OR currently loading
    if ((_availableStates.isNotEmpty || _isLoadingStates)) {
      debugPrint("⏭️ States already loaded or loading, skipping fetch");
      return;
    }

    _isLoadingStates = true;
    notifyListeners();

    try {
      debugPrint("🔄 GlobalDataManager: Fetching states from repository...");
      _availableStates = await _redemptionRepository.getAvailableStates();
      debugPrint("✅ GlobalDataManager: Got ${_availableStates.length} states");

      // Also populate locationsByState from repository cache
      for (final state in _availableStates) {
        final locations =
            await _redemptionRepository.getAllLocationsByState(state);
        if (locations.isNotEmpty) {
          _locationsByState[state] = locations;
        }
      }
      debugPrint(
          "✅ GlobalDataManager: Populated locations for ${_locationsByState.keys.length} states");
    } catch (e) {
      debugPrint("❌ Error fetching redemption states: $e");
      _availableStates = [];
    } finally {
      _isLoadingStates = false;
      notifyListeners();
    }
  }

  // Make this method return Future<void>
  Future<void> setSelectedState(String state) async {
    _selectedState = state;
    notifyListeners();
  }

  // Add new method for fetching locations by state
  Future<void> fetchLocationsByState(String state) async {
    if (_locationsByState.containsKey(state) && !_isLoadingLocations) return;

    _isLoadingLocations = true;
    notifyListeners();

    try {
      final locations =
          await _redemptionRepository.getAllLocationsByState(state);
      _locationsByState[state] = locations.cast<PropertyState>();
    } catch (e) {
      debugPrint("❌ Error fetching locations for state $state: $e");
      _locationsByState[state] = [];
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

  // Check if data needs refresh (optional: implement cache expiry)
  bool shouldRefreshData() {
    if (!_isInitialized) return true;
    if (_lastFetchTime == null) return true;

    // Refresh if data is older than 30 minutes
    final now = DateTime.now();
    final difference = now.difference(_lastFetchTime!);
    return difference.inMinutes > 30;
  }

  // Clear all cached data (useful for logout or app restart)
  void clearAllData() {
    _users.clear();
    _ownerUnits.clear();
    _unitByMonth.clear();
    _revenueDashboard.clear();
    _totalByMonth.clear();
    _locationByMonth.clear();
    _propertyContractType.clear();
    _propertyOccupancy.clear();
    _occupancyRateHistory.clear();

    _availableStates.clear();
    _locationsByState.clear();
    _filteredLocationCache.clear();

    _isInitialized = false;
    _isLoading = false;
    _lastFetchTime = null;

    notifyListeners();
  }

  // Reset and refresh all data (useful for switching users)
  Future<void> resetAndRefreshData() async {
    clearAllData();
    await initializeData(forceRefresh: true);
  }

  /// Set or clear impersonation target email.
  /// When set, subsequent initializeData will fetch user data for this email.
  void setImpersonatedEmail(String? email) {
    _impersonatedEmail = email;
    debugPrint('🔐 GlobalDataManager.setImpersonatedEmail -> $email');
  }

  Future<void> _fetchInitialOccupancyHistory() async {
    try {
      if (_ownerUnits.isNotEmpty) {
        final firstUnit = _ownerUnits.first;
        await fetchOccupancyRateHistory(
          location: firstUnit.location,
          unitNo: firstUnit.unitno,
          period: 'Monthly',
        );
      }
    } catch (e) {
      print('Error fetching initial occupancy history: $e');
    }
  }

  // Add this method to fetch occupancy rate history
  Future<void> fetchOccupancyRateHistory({
    String? location,
    String? unitNo,
    String period = 'Monthly',
  }) async {
    try {
      _occupancyRateHistory = await _propertyRepository.getOccupancyRateHistory(
        location: location,
        unitNo: unitNo,
        period: period,
      );
      notifyListeners();
    } catch (e) {
      print('Error fetching occupancy rate history: $e');
      _occupancyRateHistory = [];
      notifyListeners();
    }
  }

  // Method to get occupancy data for chart with fallback
  List<OccupancyRate> getOccupancyDataForPeriod(String period) {
    if (_occupancyRateHistory.isNotEmpty) {
      return _occupancyRateHistory;
    }

    // Generate fallback data using existing cached occupancy methods
    return _generateFallbackOccupancyData(period);
  }

  List<OccupancyRate> _generateFallbackOccupancyData(String period) {
    List<OccupancyRate> fallbackData = [];
    final currentYear = DateTime.now().year;

    switch (period) {
      case 'Monthly':
        for (int month = 1; month <= 12; month++) {
          double occupancy =
              _getAverageOccupancyByMonthFromCache(month, currentYear);
          fallbackData.add(OccupancyRate(
            year: currentYear,
            month: month,
            amount: occupancy,
          ));
        }
        break;

      case 'Quarterly':
        for (int quarter = 1; quarter <= 4; quarter++) {
          double occupancy =
              _getAverageOccupancyByQuarterFromCache(quarter, currentYear);
          fallbackData.add(OccupancyRate(
            year: currentYear,
            month: quarter * 3,
            amount: occupancy,
          ));
        }
        break;

      case 'Yearly':
        for (int i = 0; i < 4; i++) {
          final year = currentYear - 3 + i;
          double occupancy = _getAverageOccupancyByYearFromCache(year);
          fallbackData.add(OccupancyRate(
            year: year,
            month: 12,
            amount: occupancy,
          ));
        }
        break;
    }

    return fallbackData;
  }

  // Helper methods for cached occupancy calculations
  double _getAverageOccupancyByMonthFromCache(int month, int year) {
    double total = 0;
    int count = 0;

    _propertyOccupancy.forEach((location, data) {
      if (data is Map && data.containsKey('units')) {
        final units = data['units'] as Map<String, dynamic>;
        units.forEach((unitNo, unitData) {
          if (unitData is Map &&
              unitData['year'] == year &&
              unitData['month'] == month &&
              unitData['amount'] != null) {
            total += (unitData['amount'] as num).toDouble();
            count++;
          }
        });
      }
    });

    return count == 0 ? 0.0 : total / count;
  }

  double _getAverageOccupancyByQuarterFromCache(int quarter, int year) {
    int startMonth = (quarter - 1) * 3 + 1;
    double total = 0;
    int count = 0;

    for (int month = startMonth; month <= startMonth + 2; month++) {
      double monthAvg = _getAverageOccupancyByMonthFromCache(month, year);
      if (monthAvg > 0) {
        total += monthAvg;
        count++;
      }
    }

    return count == 0 ? 0.0 : total / count;
  }

  double _getAverageOccupancyByYearFromCache(int year) {
    double total = 0;
    int count = 0;

    _propertyOccupancy.forEach((location, data) {
      if (data is Map && data.containsKey('units')) {
        final units = data['units'] as Map<String, dynamic>;
        units.forEach((unitNo, unitData) {
          if (unitData is Map &&
              unitData['year'] == year &&
              unitData['amount'] != null) {
            total += (unitData['amount'] as num).toDouble();
            count++;
          }
        });
      }
    });

    return count == 0 ? 0.0 : total / count;
  }

  Future<void> preloadLocationsForState(String state) async {
    if (_filteredLocationCache.containsKey(state)) return;

    // Set loading flag when preloading starts
    if (!_isLoadingLocations) {
      _isLoadingLocations = true;
      notifyListeners();
    }

    try {
      final locations =
          await _redemptionRepository.getAllLocationsByState(state);
      // Cache the filtered locations
      _filteredLocationCache[state] = locations
          .where((loc) => loc.locationName.isNotEmpty)
          .cast<PropertyState>()
          .toList();

      // Also update the main locations state
      _locationsByState[state] = locations.cast<PropertyState>();
    } catch (e) {
      debugPrint("❌ Error preloading locations for state $state: $e");
    }
  }

  List<PropertyState> getCachedLocationsForState(String state) {
    return _filteredLocationCache[state] ?? [];
  }

  void clearLocationCache() {
    // Clear state and location related data
    _availableStates.clear();
    _locationsByState.clear();
    _filteredLocationCache.clear();

    // Reset any selected state if you have one
    _selectedState = null;
    debugPrint("✅ Location cache cleared in GlobalDataManager");
    notifyListeners();
  }

  // Clear selection cache method
  void clearSelectionCache() {
    debugPrint("✅ Selection cache cleared in GlobalDataManager");
    notifyListeners();
  }

  // Clear previous selections method
  void clearPreviousSelections() {
    debugPrint("✅ Previous selections cleared in GlobalDataManager");
    notifyListeners();
  }

  // Optional: Complete reset method
  void resetAllData() {
    // Clear all cached data (same as clearAllData but without resetting _isInitialized)
    _users.clear();
    _ownerUnits.clear();
    _unitByMonth.clear();
    _revenueDashboard.clear();
    _totalByMonth.clear();
    _locationByMonth.clear();
    _propertyContractType.clear();
    _propertyOccupancy.clear();
    _occupancyRateHistory.clear();

    _availableStates.clear();
    _locationsByState.clear();
    _filteredLocationCache.clear();
    _selectedState = null;

    debugPrint("✅ All data reset in GlobalDataManager");
    notifyListeners();
  }

  void setUsers(List<User> users) {
    _users = List<User>.from(users);
    debugPrint(
        '🔐 GlobalDataManager.setUsers -> first=${_users.isNotEmpty ? _users.first.email : 'none'} count=${_users.length}');
    notifyListeners();
  }
  // Add these methods to GlobalDataManager class

// Method to get all locations from all states (already loaded)
// Add this method to GlobalDataManager
  List<PropertyState> getAllLocationsFromAllStates() {
    List<PropertyState> allLocations = [];
    _locationsByState.forEach((state, locations) {
      allLocations.addAll(locations);
    });
    return allLocations;
  }

// Method to fetch all locations for all states
  Future<void> fetchAllLocationsForAllStates() async {
    if (_availableStates.isEmpty) {
      await fetchRedemptionStatesAndLocations();
    }

    _isLoadingLocations = true;
    notifyListeners();

    try {
      // Fetch locations for all states in parallel
      await Future.wait(
        _availableStates.map((state) async {
          try {
            final locations =
                await _redemptionRepository.getAllLocationsByState(state);
            _locationsByState[state] = locations.cast<PropertyState>();
          } catch (e) {
            debugPrint("❌ Error fetching locations for state $state: $e");
            _locationsByState[state] = [];
          }
        }),
      );
    } catch (e) {
      debugPrint("❌ Error fetching all locations: $e");
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

  void resetAndReinitialize(String switchUserEmail) async {
    debugPrint('🔄 Resetting and reinitializing GlobalDataManager...');
    resetAllData();
    setImpersonatedEmail(switchUserEmail);
    await initializeData(forceRefresh: true);
    debugPrint('✅ GlobalDataManager refreshed for $switchUserEmail');
  }

  /// Apply full impersonation data supplied by the caller.
  /// This allows the app to show complete user and owner-unit data without
  /// depending on backend responses. Useful for local fixtures or testing.
  void applyImpersonationData(
      {required User user,
      List<OwnerPropertyList>? ownerUnits,
      bool notify = true}) {
    _impersonatedEmail = user.email;
    _users = [user];
    _ownerUnits = ownerUnits ?? [];
    if (notify) notifyListeners();
    debugPrint(
        '🔧 GlobalDataManager.applyImpersonationData applied for ${user.email}');
  }

  /// Try to load impersonation data from an asset JSON file.
  /// Expected asset structure (example):
  /// {
  ///   "user": { ... },
  ///   "ownerUnits": [ { ... }, ... ]
  /// }
  /// Returns true if file was found and applied, false otherwise.
  Future<bool> loadImpersonationFromAsset(String assetPath) async {
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = json.decode(jsonStr);

      // Parse user
      User user;
      if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
        user = User.fromJson(Map<String, dynamic>.from(data['user']));
      } else {
        debugPrint('⚠️ impersonation asset missing `user` object');
        return false;
      }

      // Parse ownerUnits if provided
      List<OwnerPropertyList> ownerUnits = [];
      if (data.containsKey('ownerUnits') && data['ownerUnits'] is List) {
        final list = List<dynamic>.from(data['ownerUnits']);
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            ownerUnits.add(OwnerPropertyList.fromJson(item, 0, ''));
          }
        }
      }

      // Apply parsed data
      applyImpersonationData(user: user, ownerUnits: ownerUnits);
      debugPrint('✅ Loaded impersonation asset: $assetPath');
      return true;
    } catch (e) {
      debugPrint('⚠️ Failed to load impersonation asset $assetPath: $e');
      return false;
    }
  }

  Future<void> impersonateUser(String email) async {
    debugPrint('🧑‍💼 Starting impersonation for $email');

    if (_isImpersonating) {
      final current = _impersonatedEmail ?? '<unknown>';
      if (current.toLowerCase() == email.toLowerCase()) {
        debugPrint('⚠️ Already impersonating $email.');
        return;
      }

      debugPrint(
          '🔁 Updating impersonation from $current to $email (keeping original backup)');

      // Update target and clear caches so UI shows loading for new target.
      _impersonatedEmail = email;
      _users = [];
      _ownerUnits = [];
      _unitByMonth = [];
      _revenueDashboard = [];
      _totalByMonth = [];
      _locationByMonth = [];
      _propertyContractType = [];
      _propertyOccupancy = {};
      _occupancyRateHistory = [];

      debugPrint(
          '🔄 Cleared local user data and starting background load for $email');

      unawaited(_fetchAllData());
      notifyListeners();
      return;
    }
    final userExists = await _userRepository.userExists(email);
    if (!userExists) {
      debugPrint('❌ User $email does not exist');
      throw Exception('User not found: $email');
    }

    // Not currently impersonating — create backups and start impersonation.
    _originalUsersBackup = List<User>.from(_users);
    _originalOwnerUnits = List<OwnerPropertyList>.from(_ownerUnits);
    _originalUser = _users.isNotEmpty ? _users.first : null;
    _isImpersonating = true;

    // Set impersonated email and clear caches
    _impersonatedEmail = email;
    _users = [];
    _ownerUnits = [];
    _unitByMonth = [];
    _revenueDashboard = [];
    _totalByMonth = [];
    _locationByMonth = [];
    _propertyContractType = [];
    _propertyOccupancy = {};
    _occupancyRateHistory = [];

    debugPrint(
        '🔄 Cleared local user data and starting background load for $email');

    // Start fetching impersonated data in background. When it completes the
    // UI will be updated via notifyListeners called by the fetch routines.
    unawaited(_fetchAllData());

    notifyListeners();
  }

  Future<void> revertImpersonation() async {
    if (!_isImpersonating) {
      debugPrint('⚠️ Not currently impersonating anyone.');
      return;
    }

    debugPrint('↩️ Reverting impersonation to original user...');

    // Restore backups
    _users = List<User>.from(_originalUsersBackup);
    _ownerUnits = List<OwnerPropertyList>.from(_originalOwnerUnits);
    _impersonatedEmail = null;
    _isImpersonating = false;

    // Optionally refresh all data from backend again
    unawaited(_fetchAllData());

    notifyListeners();

    debugPrint('✅ Impersonation reverted successfully.');
  }
}
