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
          "contractType": "PS",
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
        };
      }).toList();
    }
    // print(locationByMonth.first);
    // locationByMonth = [
    //   {'total': 1842.01, 'location': 'SCARLETZ', 'month': 5, 'year': 2024},
    //   {'total': 1842.01, 'location': 'SCARLETZ', 'month': 6, 'year': 2024},
    //   {'total': 2500.01, 'location': 'SCARLETZ', 'month': 1, 'year': 2025},
    //   {'total': 2500.01, 'location': 'SCARLETZ', 'month': 2, 'year': 2025}
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

    isLoading = false;
    notifyListeners();

    propertyOccupancy =
        await ownerPropertyListRepository.getPropertyOccupancy();

    // propertyOccupancy = [
    //   {"year": 2024, "month": 9, "amount": 92.53},
    // {"year": 2024, "month": 9, "amount": 92.53}
    // ];
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    fetchData();
    notifyListeners();
  }

  String getContractType(String location) {
    final contract = propertyContractType
        .firstWhere((contract) => contract['location'] == location);
    return contract['contractType'] ?? '';
  }
}
