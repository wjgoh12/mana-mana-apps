import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_owner_state.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
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

  List<Map<String, dynamic>> revenueDashboard = [];
  List<Map<String, dynamic>> monthlyProfitOwner = [];
  List<Map<String, dynamic>> totalByMonth = [];
  List<Map<String, dynamic>> monthlyBlcOwner = [];
  List<Map<String, dynamic>> locationByMonth = [];

  Future get overallBalance => Future.delayed(
      const Duration(milliseconds: 500),
      () => revenueDashboard.isNotEmpty
          ? revenueDashboard.firstWhere((item) => item["transcode"] == "OWNBAL",
              orElse: () => {"total": 0.0})["total"]
          : 0.0).then((value) => value);
  Future get overallProfit => Future.delayed(
      const Duration(milliseconds: 500),
      () => revenueDashboard.isNotEmpty
          ? revenueDashboard.firstWhere((item) => item["transcode"] == "NOPROF",
              orElse: () => {"total": 0.0})["total"]
          : 0.0).then((value) => value);

  Future<void> fetchData() async {
    _users = await userRepository.getUsers();
    GlobalUserState.instance.setUsers(_users);
    ownerUnits = await ownerPropertyListRepository.getOwnerUnit();
    GlobalOwnerState.instance.setOwnerData(ownerUnits);
    userNameAccount = _users.isNotEmpty ? '${_users.first.ownerFullName}' : '-';

    revenueDashboard = await ownerPropertyListRepository.revenueByYear();
    totalByMonth = await ownerPropertyListRepository.totalByMonth();

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
