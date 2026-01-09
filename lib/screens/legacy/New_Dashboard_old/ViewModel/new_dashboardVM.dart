import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/owner_property_list.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class NewDashboardVM extends ChangeNotifier {
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
  List<Map<String, dynamic>> monthlyBlcOwner = [];
  List<Map<String, dynamic>> locationByMonth = [];

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

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    fetchData();
    notifyListeners();
  }
}
