import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class SettingPageVM extends ChangeNotifier {
  List<User> _users = [];
  List<User> get users => _users;
  final UserRepository userRepository = UserRepository();

  Future<void> fetchData() async {
    _users = await userRepository.getUsers();
    notifyListeners();
  }
}