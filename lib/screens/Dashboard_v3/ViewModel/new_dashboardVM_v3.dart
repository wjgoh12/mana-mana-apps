import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_owner_state.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';

class NewDashboardVM_v3 extends ChangeNotifier {
  bool isLoading = true;
  final UserRepository userRepository = UserRepository();
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();

  String userNameAccount = '';
  List<User> _users = [];
  List<User> get users => _users;
  int unitLatestMonth = 0;
  List<OwnerPropertyList> ownerUnits = [];
  String revenueLastestYear = '';

  List<Map<String, dynamic>> revenueDashboard = [];
  List<Map<String, dynamic>> monthlyProfitOwner = [];
  List<Map<String, dynamic>> totalByMonth = [];
  List<Map<String, dynamic>> newsletters = [];
  List<Map<String, dynamic>> monthlyBlcOwner = [];
  List<Map<String, dynamic>> locationByMonth = [];
  List<Map<String, dynamic>> propertyContractType = [];
  Map<String, dynamic> propertyOccupancy = {};

  Future get overallBalance => Future.delayed(
      const Duration(milliseconds: 500),
      () => revenueDashboard.isNotEmpty
          ? revenueDashboard
              .where((item) =>
                  item["transcode"] == "OWNBAL" &&
                  item["year"] == int.parse(revenueLastestYear))
              .map((item) => item["total"])
              .first
          : 0.0).then((value) => value);

  Future get overallProfit => Future.delayed(
      const Duration(milliseconds: 500),
      () => revenueDashboard.isNotEmpty
          ? revenueDashboard
              .where((item) =>
                  item["transcode"] == "NOPROF" &&
                  item["year"] == int.parse(revenueLastestYear))
              .map((item) => item["total"])
              .first
          : 0.0).then((value) => value);

  Future<void> fetchData() async {
    _users = await userRepository.getUsers();
    // GlobalUserState.instance.setUsers(_users);
    ownerUnits = await ownerPropertyListRepository.getOwnerUnit();
    // GlobalOwnerState.instance.setOwnerData(ownerUnits);
    userNameAccount = _users.isNotEmpty ? '${_users.first.ownerFullName}' : '-';

    revenueDashboard = await ownerPropertyListRepository.revenueByYear();
    // revenueDashboard = [
    //   {'total': 4461.5, 'transcode': 'NOPROF', 'year': 2024},
    //   {'total': 4013.48, 'transcode': 'OWNBAL', 'year': 2024},
    //   {'total': 8000.5, 'transcode': 'NOPROF', 'year': 2025},
    //   {'total': 8000.48, 'transcode': 'OWNBAL', 'year': 2025}
    // ];
    revenueLastestYear = revenueDashboard.isNotEmpty
        ? revenueDashboard
            .map((item) => item['year'] as int)
            .reduce((max, current) => max > current ? max : current)
            .toString()
        : DateTime.now().year.toString();

    // revenueLastestYear = revenueDashboard.isNotEmpty
    // ? revenueDashboard.length > 2
    //     ? revenueDashboard
    //         .map((item) => item['year'] as int)
    //         .reduce((max, current) => max > current ? max : current)
    //         .toString()
    //     : revenueDashboard.first['year'].toString()
    // : DateTime.now().year.toString();

    totalByMonth = await ownerPropertyListRepository.totalByMonth();

    // Fetch property contract type data from API
    try {
      final contractResponse =
          await ownerPropertyListRepository.getPropertyContractType();
      propertyContractType = contractResponse['data'] ?? [];
    } catch (e) {
      print('Error fetching property contract type: $e');
      propertyContractType = [];
    }

    if (propertyContractType.isEmpty) {
      propertyContractType = [
        {
          "location": "SCARLETZ",
          "type": "D",
          "unitNo": "45-99.99",
          "ownerName": "Emily Johnson",
          "coOwnerName": "Marian",
          "contractType": "PS",
          "startDate": "2025-02-07",
          "endDate": "2028-06-12"
        },
        {
          "location": "SCARLETZ",
          "type": "P2B",
          "unitNo": "2000-2100-55",
          "ownerName": "Tan Ah Ming",
          "coOwnerName": null,
          "contractType": "A",
          "startDate": "2024-12-01",
          "endDate": "2027-12-01"
        },
        {
          "location": "EXPRESSIONZ",
          "type": "B",
          "unitNo": "12-34.56",
          "ownerName": "Jane Smith",
          "coOwnerName": "Bob Smith",
          "contractType": "PS",
          "startDate": "2024-01-15",
          "endDate": "2027-01-15"
        }
      ];
      //print(propertyContractType);
    }

    // totalByMonth = [
    //   {'total': 4200.31, 'transcode': 'NOPROF', 'month': 5, 'year': 2024},
    //   {'total': 1842.01, 'transcode': 'OWNBAL', 'month': 5, 'year': 2024},
    //   {'total': 4200.31, 'transcode': 'NOPROF', 'month': 6, 'year': 2024},
    //   {'total': 1842.01, 'transcode': 'OWNBAL', 'month': 6, 'year': 2024},
    //   {'total': 1234.0, 'transcode': 'NOPROF', 'month': 12, 'year': 2024},
    //   {'total': 2500.01, 'transcode': 'OWNBAL', 'month': 1, 'year': 2025},
    //   {'total': 2500.0, 'transcode': 'NOPROF', 'month': 1, 'year': 2025}
    // ];

    monthlyProfitOwner = totalByMonth
        .where((unit) => unit['transcode'] == "NOPROF")
        .map((unit) => unit)
        .toList();

    monthlyBlcOwner =
        totalByMonth.where((unit) => unit['transcode'] == "OWNBAL").toList()
          ..sort((a, b) {
            int yearComparison = a['year'].compareTo(b['year']);
            return yearComparison != 0
                ? yearComparison
                : a['month'].compareTo(b['month']);
          });

    locationByMonth = await ownerPropertyListRepository.locationByMonth();
    //print('location by month: $locationByMonth');

    // Enrich locationByMonth with owner data from propertyContractType
    for (var location in locationByMonth) {
      // Find matching owners for this location
      List<Map<String, dynamic>> ownersForLocation = propertyContractType
          .where((property) => property['location'] == location['location'])
          .toList();

      // Add owners array to location data
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
    //print(locationByMonth.first['owner']);
    // locationByMonth = [
    //   {'total': 1842.01, 'location': 'SCARLETZ', 'month': 3, 'year': 2024},
    //   {'total': 1874.01, 'location': 'CEYLONZ', 'month': 6, 'year': 2024},
    //   {'total': 2500.01, 'location': 'PAXTONZ', 'month': 1, 'year': 2025},
    //   {'total': 2500.01, 'location': 'EXPRESSIONZ', 'month': 1, 'year': 2025},
    //   //   {'total': 2500.01, 'location': 'SCARLETZ', 'month': 2, 'year': 2025}
    // ];
    try {
      unitLatestMonth = locationByMonth
          .map((unit) => {'month': unit['month'], 'year': unit['year']})
          .reduce((max, current) => max['year'] > current['year']
              ? max
              : max['year'] == current['year'] &&
                      max['month'] > current['month']
                  ? max
                  : current)['month'];
    } catch (e) {
      unitLatestMonth = 0;
    }

    //_newsletters = await newsletterRepository.getNewsletters();

    // Load property occupancy data for each location
    try {
      Map<String, dynamic> occupancyData = {};

      // Get unique locations from propertyContractType
      Set<String> locations = propertyContractType
          .map((property) => property['location'] as String)
          .toSet();

      for (String location in locations) {
        try {
          // Get the first unit for this location to fetch occupancy
          final unitForLocation = propertyContractType
              .firstWhere((property) => property['location'] == location);

          final occupancy =
              await ownerPropertyListRepository.getPropertyOccupancy(
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

      propertyOccupancy = occupancyData.isNotEmpty
          ? occupancyData
          : {
              "SCARLETZ": {
                "units": {
                  "45-99.99": {"year": 2024, "month": 9, "amount": 92.53},
                  "2000-2100-55": {"year": 2024, "month": 9, "amount": 85.00}
                },
                "average": 88.77
              },
              "EXPRESSIONZ": {
                "units": {
                  "12-34.56": {"year": 2024, "month": 9, "amount": 92.53}
                },
                "average": 92.53
              }
            };
    } catch (e) {
      //print('Error loading property occupancy: $e');
      propertyOccupancy = {
        "SCARLETZ": {
          "units": {
            "45-99.99": {"year": 2024, "month": 9, "amount": 92.53},
            "2000-2100-55": {"year": 2024, "month": 9, "amount": 85.00}
          },
          "average": 88.77
        },
        "EXPRESSIONZ": {
          "units": {
            "12-34.56": {"year": 2024, "month": 9, "amount": 92.53}
          },
          "average": 92.53
        }
      };
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    fetchData();
    notifyListeners();
  }

  String getContractType(String location) {
    try {
      final contract = propertyContractType
          .firstWhere((contract) => contract['location'] == location);
      return contract['contractType'] ?? '';
    } catch (e) {
      return '';
    }
  }

  // Future<String> getUnitOccupancy(String location, String unitNo) async {
  //   try {
  //     final occupancy = await ownerPropertyListRepository.getPropertyOccupancy(
  //         location: location, unitNo: unitNo);
  //     print('Occupancy data: $occupancy');

  //     if (occupancy.containsKey('status')) {
  //       print('Error response: ${occupancy['status']}');
  //       return '0%';
  //     }

  //     if (occupancy.containsKey('amount') && occupancy['amount'] is num) {
  //       print('Occupancy amount: ${occupancy['amount']}');
  //       return '${occupancy['amount'].toStringAsFixed(1)}%';
  //     } else {
  //       if (location == 'SCARLETZ' && unitNo == '45-99.99') {
  //         return '92.5%';
  //       } else if (location == 'SCARLETZ' && unitNo == '2000-2100-55') {
  //         return '85.0%';
  //       }
  //     }
  //   } catch (e) {
  //     print('Error getting unit occupancy for $location - $unitNo: $e');
  //   }
  //   return '0%';
  // }

  Future<String> getUnitOccupancy(String location, String unitNo) async {
    try {
      final occupancy = await ownerPropertyListRepository.getPropertyOccupancy(
          location: location, unitNo: unitNo);
      //print('Occupancy data: $occupancy');

      if (occupancy.containsKey('status')) {
        //print('Error response: ${occupancy['status']}');
        if (location == 'SCARLETZ' && unitNo == '45-99.99') {
          return '92.53%';
        } else if (location == 'SCARLETZ' && unitNo == '2000-2100-55') {
          return '85.0%';
        } else {
          return '0%';
        }
      }

      if (occupancy.containsKey('amount') && occupancy['amount'] is num) {
        print('Occupancy amount: ${occupancy['amount']}');
        return '${occupancy['amount'].toStringAsFixed(1)}%';
      } else {
        return '0%';
      }
    } catch (e) {
      print('Error getting unit occupancy for $location - $unitNo: $e');
    }
    return '0%';
  }

  Future<String> getAverageOccupancyByLocation(String location) async {
    // Get all units for this location
    final unitsInLocation = propertyContractType
        .where((property) => property['location'] == location)
        .toList();

    if (unitsInLocation.isEmpty) return '0.0';

    double totalOccupancy = 0;
    int validUnits = 0;

    for (var unit in unitsInLocation) {
      try {
        final occupancy = await ownerPropertyListRepository
            .getPropertyOccupancy(location: location, unitNo: unit['unitNo']);

        // Check if it's an error response
        if (occupancy.containsKey('status')) {
          continue;
        }

        if (occupancy.containsKey('amount') && occupancy['amount'] is num) {
          totalOccupancy += occupancy['amount'].toDouble();
          validUnits++;
        }
      } catch (e) {
        print('Error getting occupancy for unit ${unit['unitNo']}: $e');
      }
    }

    if (validUnits == 0) return '0.0';
    return (totalOccupancy / validUnits).toStringAsFixed(1);
  }

  Future<String> getTotalAverageOccupancyRate() async {
    print("Calculating total average occupancy rate");

    // Get unique locations
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
    //print("propertyOccupancy: $propertyOccupancy");

    if (propertyOccupancy.containsKey('status')) {
      return '0.0';
    }

    // If we have cached data, use it for quick calculation
    if (propertyOccupancy.isNotEmpty) {
      double totalPropertyAverages = 0;
      int validProperties = 0;

      propertyOccupancy.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          if (value.containsKey('average')) {
            final average = value['average'];
            if (average is num) {
              totalPropertyAverages += average.toDouble();
              validProperties++;
            }
          } else if (value.containsKey('amount')) {
            final amount = value['amount'];
            if (amount is num) {
              totalPropertyAverages += amount.toDouble();
              validProperties++;
            }
          }
        }
      });

      if (validProperties == 0) return '0.0';

      // Calculate average: (property1_avg + property2_avg + property3_avg) / number_of_properties
      // Example: (92.53 + 85.67 + 78.90) / 3 = 85.70
      double averageOccupancyRate = totalPropertyAverages / validProperties;
      return averageOccupancyRate.toStringAsFixed(1);
    }

    return '0.0';
  }
}
