import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class DashboardVM extends ChangeNotifier {
  static final DashboardVM _instance = DashboardVM._internal();

  factory DashboardVM() {
    return _instance;
  }
  DashboardVM._internal();

  @override
  void onModelReady() {
    fetchUsers();
  }

  final UserRepository user_repository = UserRepository();
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> fetchUsers() async {
    _users = await user_repository.getUsers();
    userNameAccount = _users.isNotEmpty ? '${_users.first.firstName} ${_users.first.lastName}' : '';
    print(_users.first.firstName);
    notifyListeners();
  }

  String overallRevenueAmount = '0';
  String userNameAccount = '';
  int abc = 0;
  

  void updateOverallRevenueAmount() {
    print('testing');
    abc ++;
    overallRevenueAmount = abc.toString();
    notifyListeners();
  }
}
