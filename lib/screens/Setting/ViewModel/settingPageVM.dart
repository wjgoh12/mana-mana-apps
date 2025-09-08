import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class SettingPageVM extends ChangeNotifier {
  final GlobalDataManager _globalDataManager = GlobalDataManager();

  // Getters that delegate to GlobalDataManager
  List<User> get users => _globalDataManager.users;

  Future<void> fetchData() async {
    // Use global data manager instead of making individual API calls
    await _globalDataManager.initializeData();
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();
    notifyListeners();
  }
}