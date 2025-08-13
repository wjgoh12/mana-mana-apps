import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class OwnerProfileVM extends ChangeNotifier {
  bool _showMyInfo = true;
  List<User> _users = [];
  List<User> get users => _users;
  List<OwnerPropertyList> _ownerUnits = [];
  List<OwnerPropertyList> get ownerUnits => _ownerUnits;
  final UserRepository userRepository = UserRepository();
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();

  bool get showMyInfo => _showMyInfo;

  // Add helper methods to safely access data
  String getOwnerName() {
    if (_users.isEmpty) return 'No Information';
    return _users.first.ownerFullName?.toString() ?? 'No Information';
  }

  String getOwnerContact() {
    if (_users.isEmpty) return 'No Information';
    return _users.first.ownerContact?.toString() ?? 'No Information';
  }

  String getOwnerEmail() {
    if (_users.isEmpty) return 'No Information';
    return _users.first.ownerEmail?.toString() ?? 'No Information';
  }

  String getOwnerAddress() {
    if (_users.isEmpty) return 'No Information';
    return _users.first.ownerAddress?.toString() ?? 'No Information';
  }

  String getBankInfo() {
    if (_ownerUnits.isEmpty) return 'No Information';
    return _ownerUnits.first.bank?.toString() ?? 'No Information';
  }

  String getAccountNumber() {
    if (_ownerUnits.isEmpty) return 'No Information';
    return _ownerUnits.first.accountnumber?.toString() ?? 'No Information';
  }

  Future<void> fetchData() async {
    _users = await userRepository.getUsers();
    _ownerUnits = await ownerPropertyListRepository.getOwnerUnit();
    //_ownerBookingHistory = await ownerBookingHistoryRepository.getOwnerBookingHistory();???
    notifyListeners();
  }

  void updateShowMyInfo(bool value) {
    _showMyInfo = value;
    notifyListeners();
  }
}
