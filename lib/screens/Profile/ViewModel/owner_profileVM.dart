import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class OwnerProfileVM extends ChangeNotifier {
  bool _showMyInfo = true;
  final GlobalDataManager _globalDataManager = GlobalDataManager();
  final UserPointBalance = [];
  final RedemptionRepository OwnerBookingRepository = RedemptionRepository();

  bool get showMyInfo => _showMyInfo;

  // Getters that delegate to GlobalDataManager
  List<User> get users => _globalDataManager.users;
  List<OwnerPropertyList> get ownerUnits => _globalDataManager.ownerUnits;

  // Add helper methods to safely access data
  String getOwnerName() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerFullName?.toString() ?? 'No Information';
  }

  String getOwnerContact() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerContact?.toString() ?? 'No Information';
  }

  String getOwnerEmail() {
    if (users.isEmpty) return 'No Information';
    return users.first.email?.toString() ?? 'No Information';
  }

  String getOwnerAddress() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerAddress?.toString() ?? 'No Information';
  }

  String getBankInfo() {
    if (ownerUnits.isEmpty) return 'No Information';
    return ownerUnits.first.bank?.toString() ?? 'No Information';
  }

  String getAccountNumber() {
    if (ownerUnits.isEmpty) return 'No Information';
    return ownerUnits.first.accountnumber?.toString() ?? 'No Information';
  }

  Future<void> fetchData() async {
    // Use global data manager instead of making individual API calls
    await _globalDataManager.initializeData();
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();
    notifyListeners();
  }

  void updateShowMyInfo(bool value) {
    _showMyInfo = value;
    notifyListeners();
  }
}
