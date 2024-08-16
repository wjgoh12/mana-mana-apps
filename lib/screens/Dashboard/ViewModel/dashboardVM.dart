import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_owner_state.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class DashboardVM extends ChangeNotifier {
  static final DashboardVM _instance = DashboardVM._internal();
  static bool _isInitialized = false;
  bool isLoading = true;
  factory DashboardVM() {
    if (!_isInitialized) {
      _isInitialized = true;
      _instance.fetchUsers();
    }
    return _instance;
  }
  DashboardVM._internal();
  // DashboardVM._internal() {
  //   fetchUsers();
  // }

  final UserRepository user_repository = UserRepository();
  final PropertyListRepository ownerPropertyList_repository = PropertyListRepository();
  List<User> _users = [];
  List<OwnerPropertyList> ownerUnits = [];
  List<Map<String, dynamic>> revenue_dashboard = [];
  List<Map<String, dynamic>> locationByMonth = [];
  List<Map<String, dynamic>> totalByMonth = [];
  List<Map<String, dynamic>> monthlyBlcOwner = [];
  List<Map<String, dynamic>> monthlyProfitOwner = [];
  int unitLatestMonth = 0;
  Future get overallBalance => Future.delayed(Duration(milliseconds: 500), () => revenue_dashboard.isNotEmpty ? revenue_dashboard.firstWhere((item) => item["transcode"] == "OWNBAL", orElse: () => {"total": 0.0})["total"] : 0.0).then((value) => value);
  Future get overallProfit => Future.delayed(Duration(milliseconds: 500), () => revenue_dashboard.isNotEmpty ? revenue_dashboard.firstWhere((item) => item["transcode"] == "NOPROF", orElse: () => {"total": 0.0})["total"] : 0.0).then((value) => value);  
  int get currentYear => revenue_dashboard.isNotEmpty ? revenue_dashboard.first["iyear"] : DateTime.now().year;

  void updateData(List<Map<String, dynamic>> newData) {
    revenue_dashboard = newData;
    notifyListeners();
  }

  String overallRevenueAmount = '0';
  String userNameAccount = '';
  List<User> get users => _users;

  Future<void> fetchUsers() async {
    _users = await user_repository.getUsers();
    GlobalUserState.instance.setUsers(_users);
    userNameAccount = _users.isNotEmpty ? '${_users.first.ownerFullName}' : '';
    revenue_dashboard = await ownerPropertyList_repository.revenueByYear();
    totalByMonth = await ownerPropertyList_repository.totalByMonth();
    ownerUnits = await ownerPropertyList_repository.getOwnerUnit();

    monthlyBlcOwner = totalByMonth
        .where((unit) => unit['transcode'] == "OWNBAL" && unit['year'] == DateTime.now().year)
        .toList()
      ..sort((a, b) => a['month'].compareTo(b['month']));        
    monthlyProfitOwner = totalByMonth.where((unit) => unit['transcode'] == "NOPROF").map((unit) => unit).toList();
    GlobalOwnerState.instance.setOwnerData(ownerUnits);   
    locationByMonth = await ownerPropertyList_repository.locationByMonth();
    
    unitLatestMonth = locationByMonth
    .where((unit) => unit['year'] == DateTime.now().year)
    .map((unit) => unit['month'])
    .fold(0, (max, month) => month > max ? month : max);
    // unitLatestMonth = locationByMonth
    //     .where((unit) => unit['year'] == DateTime.now().year)
    //     .map((unit) => unit['month'])
    //     .reduce((max, month) => month > max ? month : max); 
    notifyListeners();
    isLoading = false;
    print('run fetchUsers');
    await Future.delayed(const Duration(seconds: 1)); 
    _isInitialized = false;
  }

  void updateOverallRevenueAmount() {
    // notifyListeners();
    print("clicked");
  }
}