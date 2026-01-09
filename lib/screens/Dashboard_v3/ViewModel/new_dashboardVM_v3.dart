import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/occupancy_rate.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property_new.dart';
import 'package:mana_mana_app/widgets/new_features_dialog.dart';
import 'package:mana_mana_app/widgets/notice_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class NewDashboardVM_v3 extends ChangeNotifier {
  static const String _hasExploredFeaturesKey = 'has_explored_new_features';
  static const String _hasSeenNoticeDialogKey = 'has_seen_notice_dialog_v1';

  bool contractTypeLoaded = false;
  bool occupancyRateLoaded = false;
  bool _hasShownNewFeaturesDialog = false;
  bool _hasShownNoticeDialog = false;
  bool _userHasExploredFeatures = false;
  bool _userHasSeenNotice = false;

  bool isLoading = true;
  final GlobalDataManager _globalDataManager = GlobalDataManager();
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();

  NewDashboardVM_v3() {
    _loadExploredFeaturesState();
    _loadNoticeDialogState();
  }

  Future<void> _loadExploredFeaturesState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userHasExploredFeatures =
          prefs.getBool(_hasExploredFeaturesKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading explored features state: $e');
    }
  }

  Future<void> _loadNoticeDialogState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userHasSeenNotice = prefs.getBool(_hasSeenNoticeDialogKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading notice dialog state: $e');
    }
  }

  Future<void> _saveExploredFeaturesState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasExploredFeaturesKey, _userHasExploredFeatures);
    } catch (e) {
      print('Error saving explored features state: $e');
    }
  }

  Future<void> _saveNoticeDialogState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenNoticeDialogKey, _userHasSeenNotice);
    } catch (e) {
      print('Error saving notice dialog state: $e');
    }
  }

  Future<void> resetNewFeaturesDialog() async {
    _userHasExploredFeatures = false;
    _hasShownNewFeaturesDialog = false;
    await _saveExploredFeaturesState();
    notifyListeners();
  }

  Future<void> resetNoticeDialog() async {
    _userHasSeenNotice = false;
    _hasShownNoticeDialog = false;
    await _saveNoticeDialogState();
    notifyListeners();
  }

  String get userNameAccount => _globalDataManager.userNameAccount;
  List<User> get users => _globalDataManager.users;
  List<OwnerPropertyList> get ownerUnits => _globalDataManager.ownerUnits;
  String get revenueLastestYear => _globalDataManager.revenueLatestYear;

  List<Map<String, dynamic>> get revenueDashboard =>
      _globalDataManager.revenueDashboard;
  List<Map<String, dynamic>> get monthlyProfitOwner =>
      _globalDataManager.getMonthlyProfitOwner();
  List<Map<String, dynamic>> get totalByMonth =>
      _globalDataManager.totalByMonth;
  List<Map<String, dynamic>> get newsletters => [];
  List<Map<String, dynamic>> get monthlyBlcOwner =>
      _globalDataManager.getMonthlyBlcOwner();
  List<Map<String, dynamic>> get locationByMonth =>
      _globalDataManager.locationByMonth;
  List<Map<String, dynamic>> get propertyContractType =>
      _globalDataManager.propertyContractType;
  Map<String, dynamic> get propertyOccupancy =>
      _globalDataManager.propertyOccupancy;
  List<OccupancyRate> get occupancyRateHistory =>
      _globalDataManager.occupancyRateHistory;

  int get unitLatestMonth => _globalDataManager.getUnitLatestMonth();

  Future get overallBalance => _globalDataManager.getOverallBalance();
  Future get overallProfit => _globalDataManager.getOverallProfit();

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      await _globalDataManager.initializeData();

      contractTypeLoaded = _globalDataManager.propertyContractType.isNotEmpty;
      occupancyRateLoaded = _globalDataManager.propertyOccupancy.isNotEmpty;

      _preloadLocationDataInBackground();
    } catch (e) {
      print('Error fetching dashboard data: $e');
      contractTypeLoaded = false;
      occupancyRateLoaded = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _preloadLocationDataInBackground() async {
    try {
      await _globalDataManager.fetchRedemptionStatesAndLocations();

      if (_globalDataManager.availableStates.isNotEmpty) {
        await Future.wait(
          _globalDataManager.availableStates.map(
            (state) => _globalDataManager.preloadLocationsForState(state),
          ),
        );

        _globalDataManager.clearLocationLoadingFlag();

        int totalLocations =
            _globalDataManager.getAllLocationsFromAllStates().length;
        print(
            '✅ Location data preloaded successfully. Total locations: $totalLocations');
      }
    } catch (e) {
      print('❌ Error preloading location data: $e');

      _globalDataManager.clearLocationLoadingFlag();
    }
  }

  void checkAndShowNewFeaturesDialog(BuildContext context) {
    if (!isLoading &&
        !_hasShownNewFeaturesDialog &&
        !_userHasExploredFeatures) {
      _showNewFeaturesDialog(context);
      _hasShownNewFeaturesDialog = true;
    }
  }

  void checkAndShowNoticeDialog(BuildContext context) {
    if (!isLoading && !_hasShownNoticeDialog && !_userHasSeenNotice) {
      _showNoticeDialog(context);
      _hasShownNoticeDialog = true;
    }
  }

  void _showNewFeaturesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return NewFeaturesDialog(
          onExploreNow: () async {
            _userHasExploredFeatures = true;
            await _saveExploredFeaturesState();
            Navigator.pushReplacement(
                context,
                _createRoute(const AllPropertyNewScreen(),
                    transitionType: 'fade'));
          },
        );
      },
    );
  }

  void _showNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const NoticeDialog();
      },
    ).then((_) async {
      _userHasSeenNotice = true;
      await _saveNoticeDialogState();
      notifyListeners();
    });
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();

    contractTypeLoaded = _globalDataManager.propertyContractType.isNotEmpty;
    occupancyRateLoaded = _globalDataManager.propertyOccupancy.isNotEmpty;

    notifyListeners();
  }

  String getContractType(String location) {
    return _globalDataManager.getContractType(location);
  }

  Future<String> getUnitOccupancy(String location, String unitNo) async {
    return getUnitOccupancyFromCache(location, unitNo);
  }

  Future<String> getUnitOccupancyMonthYear(
      String location, String unitNo) async {
    if (propertyOccupancy.containsKey(location)) {
      final locationData = propertyOccupancy[location];
      if (locationData is Map<String, dynamic> &&
          locationData.containsKey('units') &&
          locationData['units'] is Map<String, dynamic>) {
        final units = locationData['units'] as Map<String, dynamic>;
        if (units.containsKey(unitNo)) {
          final unitData = units[unitNo];
          if (unitData is Map<String, dynamic> &&
              unitData.containsKey('month') &&
              unitData.containsKey('year')) {
            final monthNum = unitData['month'];
            final year = unitData['year'];
            final monthName = _monthNumberToName[monthNum] ?? '';
            return '$monthName $year';
          }
        }
      }
    }

    final now = DateTime.now();
    final monthName = _monthNumberToName[now.month] ?? '';
    return '$monthName ${now.year}';
  }

  Future<String> getAverageOccupancyByLocation(String location) async {
    if (propertyOccupancy.containsKey(location)) {
      final locationData = propertyOccupancy[location];
      if (locationData is Map<String, dynamic> &&
          locationData.containsKey('average')) {
        return locationData['average'].toString();
      } else if (locationData is Map<String, dynamic> &&
          locationData.containsKey('amount')) {
        return locationData['amount'].toString();
      }
    }
    return '0.0';
  }

  Future<String> getTotalAverageOccupancyRate() async {
    Set<String> locations = propertyContractType
        .map((property) => property['location'] as String)
        .toSet();

    if (locations.isEmpty) return '0.0';

    double totalPropertyAverages = 0;
    int validProperties = 0;

    for (String location in locations) {
      final locationAverage = await getAverageOccupancyByLocation(location);
      final averageValue = double.tryParse(locationAverage) ?? 0.0;

      if (averageValue > 0) {
        totalPropertyAverages += averageValue;
        validProperties++;
      }
    }

    if (validProperties == 0) return '0.0';
    return (totalPropertyAverages / validProperties).toStringAsFixed(1);
  }

  Future<String> calculateTotalOccupancyForLocation(String location) async {
    return getAverageOccupancyByLocation(location);
  }

  final Map<int, String> _monthNumberToName = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  String getUnitOccupancyFromCache(String location, String unitNo) {
    if (propertyOccupancy.containsKey('status')) {
      return '0';
    }

    if (propertyOccupancy.containsKey(location)) {
      final locationData = propertyOccupancy[location];
      if (locationData is Map<String, dynamic>) {
        if (locationData.containsKey('amount')) {
          return locationData['amount']?.toString() ?? '0';
        }

        if (locationData.containsKey('units') &&
            locationData['units'] is Map<String, dynamic>) {
          final units = locationData['units'] as Map<String, dynamic>;
          if (units.containsKey(unitNo)) {
            final unitData = units[unitNo];
            if (unitData is Map<String, dynamic> &&
                unitData.containsKey('amount')) {
              return unitData['amount']?.toString() ?? '0';
            }
          }
        }
      }
    }

    return _calculateOccupancyFromOwners(location, unitNo);
  }

  String _calculateOccupancyFromOwners(String location, String unitNo) {
    try {
      final currentLocation = locationByMonth.firstWhere(
        (loc) => loc['location'] == location,
        orElse: () => {},
      );

      if (currentLocation.containsKey('owners')) {
        final owners = currentLocation['owners'] as List<dynamic>;
        final now = DateTime.now();

        int activeContracts = 0;
        int totalUnits = 0;

        for (var owner in owners) {
          if (owner is Map<String, dynamic>) {
            if (owner.containsKey('unitNo')) {
              totalUnits++;

              final startDateStr = owner['startDate'] as String?;
              final endDateStr = owner['endDate'] as String?;
              final contractType = owner['contractType'] as String?;

              if (startDateStr != null &&
                  endDateStr != null &&
                  contractType != null) {
                try {
                  final startDate = DateTime.parse(startDateStr);
                  final endDate = DateTime.parse(endDateStr);

                  if (now.isAfter(startDate) && now.isBefore(endDate)) {
                    activeContracts++;
                  }
                  // ignore: empty_catches
                } catch (e) {}
              }
            }
          }
        }

        if (totalUnits > 0) {
          final occupancyRate = (activeContracts / totalUnits) * 100;
          return occupancyRate.toStringAsFixed(2);
        }
      }
    } catch (e) {
      print('Error calculating occupancy from owners: $e');
    }

    return '0';
  }

  String getOccupancyByLocation(String location) {
    if (propertyOccupancy.containsKey('status')) {
      return '0';
    }

    if (propertyOccupancy.containsKey(location)) {
      final locationData = propertyOccupancy[location];
      if (locationData is Map<String, dynamic>) {
        if (locationData.containsKey('average')) {
          return locationData['average']?.toString() ?? '0';
        } else if (locationData.containsKey('amount')) {
          return locationData['amount']?.toString() ?? '0';
        }
      }
    }

    return '0';
  }

  String getTotalOccupancyRate() {
    if (propertyOccupancy.isEmpty) return '0.0';

    double totalPropertyAverages = 0;
    int validProperties = 0;

    propertyOccupancy.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        if (value.containsKey('units') && (value['units'] as Map).isNotEmpty) {
          if (value.containsKey('average') && value['average'] is num) {
            final avg = value['average'] as num;
            if (avg > 0) {
              totalPropertyAverages += avg.toDouble();
              validProperties++;
            }
          } else if (value.containsKey('amount') && value['amount'] is num) {
            final amt = value['amount'] as num;
            if (amt > 0) {
              totalPropertyAverages += amt.toDouble();
              validProperties++;
            }
          }
        }
      }
    });

    if (validProperties == 0) return '0.0';

    double averageOccupancyRate = totalPropertyAverages / validProperties;
    return averageOccupancyRate.toStringAsFixed(1);
  }

  double getAverageOccupancyByMonthCached(int month, int year) {
    double total = 0;
    int count = 0;

    propertyOccupancy.forEach((location, data) {
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

    if (count == 0) return 0.0;
    return total / count;
  }

  double getAverageOccupancyByQuarterCached(int quarter, int year) {
    int startMonth = (quarter - 1) * 3 + 1;
    double total = 0;
    int count = 0;

    for (int month = startMonth; month <= startMonth + 2; month++) {
      double monthAvg = getAverageOccupancyByMonthCached(month, year);
      if (monthAvg > 0) {
        total += monthAvg;
        count++;
      }
    }

    if (count == 0) return 0.0;
    return total / count;
  }

  double getAverageOccupancyByYearCached(int year) {
    double total = 0;
    int count = 0;

    propertyOccupancy.forEach((location, data) {
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

    if (count == 0) return 0.0;
    return total / count;
  }

  Future<void> fetchOccupancyRateHistory({
    String? location,
    String? unitNo,
    String period = 'Monthly',
  }) async {
    await _globalDataManager.fetchOccupancyRateHistory(
      location: location,
      unitNo: unitNo,
      period: period,
    );
    notifyListeners();
  }

  List<OccupancyRate> getOccupancyDataForPeriod(String period) {
    return _globalDataManager.getOccupancyDataForPeriod(period);
  }

  PageRouteBuilder _createRoute(Widget page,
      {String transitionType = 'slide'}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case 'fade':
            return FadeTransition(opacity: animation, child: child);

          case 'scale':
            return ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );

          case 'slideUp':
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );

          case 'slideLeft':
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );

          default:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
        }
      },
    );
  }
}
