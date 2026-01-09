import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';

class SettingPageVM extends ChangeNotifier {
  final GlobalDataManager _globalDataManager = GlobalDataManager();

  List<User> get users => _globalDataManager.users;

  Future<void> fetchData() async {
    await _globalDataManager.initializeData();
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();
    notifyListeners();
  }
}
