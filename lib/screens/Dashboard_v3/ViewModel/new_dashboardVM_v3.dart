import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/occupancy_rate.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';

class NewDashboardVM_v3 extends ChangeNotifier {
  bool contractTypeLoaded = false;
  bool occupancyRateLoaded = false;

  bool isLoading = true;
  final GlobalDataManager _globalDataManager = GlobalDataManager();
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();

  // Getters that delegate to GlobalDataManager
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
  List<Map<String, dynamic>> get newsletters =>
      []; // TODO: Add to GlobalDataManager if needed
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
      // Initialize global data if not already done
      await _globalDataManager.initializeData();

      // Set loading flags based on data availability
      contractTypeLoaded = _globalDataManager.propertyContractType.isNotEmpty;
      occupancyRateLoaded = _globalDataManager.propertyOccupancy.isNotEmpty;
    } catch (e) {
      print('Error fetching dashboard data: $e');
      contractTypeLoaded = false;
      occupancyRateLoaded = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();

    // Update loading flags
    contractTypeLoaded = _globalDataManager.propertyContractType.isNotEmpty;
    occupancyRateLoaded = _globalDataManager.propertyOccupancy.isNotEmpty;

    notifyListeners();
  }

  String getContractType(String location) {
    return _globalDataManager.getContractType(location);
  }

  // Use cached data instead of making API calls
  Future<String> getUnitOccupancy(String location, String unitNo) async {
    // Return cached data immediately instead of making API call
    return getUnitOccupancyFromCache(location, unitNo);
  }

  Future<String> getUnitOccupancyMonthYear(
      String location, String unitNo) async {
    // Use cached data for month/year info
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

    // fallback to current month/year if cached data missing
    final now = DateTime.now();
    final monthName = _monthNumberToName[now.month] ?? '';
    return '$monthName ${now.year}';
  }

  Future<String> getAverageOccupancyByLocation(String location) async {
    // Use cached data instead of making individual API calls per unit
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
    // Use cached data for total calculation
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
    // Use cached data instead of making fresh API calls
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

  // Get occupancy for a specific unit from cached data
  String getUnitOccupancyFromCache(String location, String unitNo) {
    // Check if propertyOccupancy contains error response
    if (propertyOccupancy.containsKey('status')) {
      return '0';
    }

    // Try to get occupancy from propertyOccupancy map
    if (propertyOccupancy.containsKey(location)) {
      final locationData = propertyOccupancy[location];
      if (locationData is Map<String, dynamic> &&
          locationData.containsKey('units') &&
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
        // ✅ only accept if it has units and average/amount > 0
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

//GET AVERAGE OCCUPANCY FROM MONTH
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

//GET AVERAGE OCCUPANCY FROM QUARTER
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

//GET AVERAGE OCCUPANCY FROM EACH YEAR
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
    notifyListeners(); // Notify listeners in case they're listening to this VM
  }

  List<OccupancyRate> getOccupancyDataForPeriod(String period) {
    return _globalDataManager.getOccupancyDataForPeriod(period);
  }
}
