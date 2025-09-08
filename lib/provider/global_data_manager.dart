import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class GlobalDataManager extends ChangeNotifier {
  static final GlobalDataManager _instance = GlobalDataManager._internal();
  factory GlobalDataManager() => _instance;
  GlobalDataManager._internal();

  // Repositories
  final UserRepository _userRepository = UserRepository();
  final PropertyListRepository _propertyRepository = PropertyListRepository();

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

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  List<User> get users => List.unmodifiable(_users);
  List<OwnerPropertyList> get ownerUnits => List.unmodifiable(_ownerUnits);
  List<SingleUnitByMonth> get unitByMonth => List.unmodifiable(_unitByMonth);
  List<Map<String, dynamic>> get revenueDashboard => List.unmodifiable(_revenueDashboard);
  List<Map<String, dynamic>> get totalByMonth => List.unmodifiable(_totalByMonth);
  List<Map<String, dynamic>> get locationByMonth => List.unmodifiable(_locationByMonth);
  List<Map<String, dynamic>> get propertyContractType => List.unmodifiable(_propertyContractType);
  Map<String, dynamic> get propertyOccupancy => Map.unmodifiable(_propertyOccupancy);

  String get userNameAccount => _users.isNotEmpty ? _users.first.ownerFullName ?? '-' : '-';
  
  String get revenueLatestYear => _revenueDashboard.isNotEmpty
      ? _revenueDashboard
          .map((item) => item['year'] as int)
          .reduce((max, current) => max > current ? max : current)
          .toString()
      : DateTime.now().year.toString();

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
      
      _isInitialized = true;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Error initializing global data: $e');
      // Don't set initialized to true if there's an error
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final contractResponse = await _propertyRepository.getPropertyContractType(email: email);
      _propertyContractType = List<Map<String, dynamic>>.from(contractResponse);
    } catch (e) {
      print('Error fetching property contract type: $e');
      _propertyContractType = [];
    }

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
    return _totalByMonth
        .where((unit) => unit['transcode'] == "OWNBAL")
        .toList()
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
        .where((unit) => 
            unit.sunitno == unitNo && 
            unit.iyear?.toString() == year)
        .map((unit) => unit.imonth?.toString() ?? '')
        .where((month) => month.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
  }

  SingleUnitByMonth? getSelectedUnitData(String unitNo, String transCode, int? year, int? month) {
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
}