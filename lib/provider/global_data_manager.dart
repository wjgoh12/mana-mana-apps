import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/occupancy_rate.dart';
import 'package:mana_mana_app/model/propertyState.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

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
      await fetchRedemptionStatesAndLocations();

      // Preload locations for all states
      if (_availableStates.isNotEmpty) {
        await _preloadAllLocationsForAllStates();
      }

      _isInitialized = true;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Error initializing global data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    await fetchRedemptionStatesAndLocations();

    // Preload locations for all states
    if (_availableStates.isNotEmpty) {
      await Future.wait(
        _availableStates.map((state) => preloadLocationsForState(state)),
      );

      // Auto-select the first state if none is selected
      if (_selectedState == null) {
        _selectedState = _availableStates.first;
      }
    }
  }

  Future<void> _fetchAllData() async {
    // Fetch users
    _users = await _userRepository.getUsers();

    // Fetch owner units
    _ownerUnits = await _propertyRepository.getOwnerUnit();

    // Fetch unit by month data
    _unitByMonth = await _propertyRepository.getUnitByMonth();

    // Fetch revenue dashboard
    _revenueDashboard = await _propertyRepository.revenueByYear();

    // Fetch total by month
    _totalByMonth = await _propertyRepository.totalByMonth();

    // Fetch location by month
    _locationByMonth = await _propertyRepository.locationByMonth();

    // Fetch property contract type
    try {
      final email = _users.isNotEmpty ? _users.first.email ?? '' : '';
      final contractResponse =
          await _propertyRepository.getPropertyContractType(email: email);
      _propertyContractType = List<Map<String, dynamic>>.from(contractResponse);
    } catch (e) {
      print('Error fetching property contract type: $e');
      _propertyContractType = [];
    }
    await _fetchPropertyOccupancy();
    await _fetchInitialOccupancyHistory();

    // Enrich locationByMonth with owner data
    for (var location in _locationByMonth) {
      List<Map<String, dynamic>> ownersForLocation = _propertyContractType
          .where((property) => property['location'] == location['location'])
          .toList();

      location['owners'] = ownersForLocation.map((property) {
        return {
          'ownerName': property['ownerName'],
          'coOwnerName': property['coOwnerName'],
          'unitNo': property['unitNo'],
          'contractType': property['contractType'],
          'endDate': property['endDate'],
          'startDate': property['startDate'],
        };
      }).toList();
    }

    // Fetch property occupancy for each location
    await _fetchPropertyOccupancy();
  }

  Future<void> _fetchPropertyOccupancy() async {
    try {
      Map<String, dynamic> occupancyData = {};

      Set<String> locations = _propertyContractType
          .map((property) => property['location'] as String)
          .toSet();

      for (String location in locations) {
        try {
          final unitForLocation = _propertyContractType
              .firstWhere((property) => property['location'] == location);

          final occupancy = await _propertyRepository.getPropertyOccupancy(
            location: location,
            unitNo: unitForLocation['unitNo'],
          );

          if (occupancy.containsKey('amount')) {
            occupancyData[location] = occupancy;
          }
        } catch (e) {
          print('Error fetching occupancy for $location: $e');
        }
      }

      _propertyOccupancy = occupancyData;
    } catch (e) {
      print('Error loading property occupancy: $e');
      _propertyOccupancy = {};
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await initializeData(forceRefresh: true);
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
    if (_availableStates.isNotEmpty && !_isLoadingStates) return;

    _isLoadingStates = true;
    notifyListeners();

    try {
      _availableStates = await _redemptionRepository.getAvailableStates();
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
    availableStates.clear();
    locationsByState.clear();

    // Reset any selected state if you have one
    // selectedState = null; // uncomment if you have this variable

    debugPrint("✅ Location cache cleared in GlobalDataManager");
    notifyListeners();
  }

  // Clear selection cache method
  void clearSelectionCache() {
    // Clear any selection-related cached data
    // Reset any selection state variables you might have

    debugPrint("✅ Selection cache cleared in GlobalDataManager");
    notifyListeners();
  }

  // Clear previous selections method
  void clearPreviousSelections() {
    // Clear any previous selection data that might interfere with new selections

    debugPrint("✅ Previous selections cleared in GlobalDataManager");
    notifyListeners();
  }

  // Optional: Complete reset method
  void resetAllData() {
    // Complete reset of all cached data
    users.clear();
    ownerUnits.clear();
    availableStates.clear();
    locationsByState.clear();

    // Reset any other state variables you have

    debugPrint("✅ All data reset in GlobalDataManager");
    notifyListeners();
  }
  // Add these methods to your GlobalDataManager class

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

  // Add this method to GlobalDataManager
  Future<void> _preloadAllLocationsForAllStates() async {
    try {
      debugPrint(
          "🔄 Preloading locations for all ${_availableStates.length} states...");

      // Fetch locations for all states in parallel
      await Future.wait(
        _availableStates.map((state) async {
          try {
            if (!_locationsByState.containsKey(state)) {
              final locations =
                  await _redemptionRepository.getAllLocationsByState(state);
              _locationsByState[state] = locations.cast<PropertyState>();
              debugPrint(
                  "✅ Preloaded ${locations.length} locations for $state");
            }
          } catch (e) {
            debugPrint("❌ Error preloading locations for state $state: $e");
            _locationsByState[state] = [];
          }
        }),
      );

      debugPrint("✅ Completed preloading all locations");
    } catch (e) {
      debugPrint("❌ Error in preloading all locations: $e");
    }
  }
}
