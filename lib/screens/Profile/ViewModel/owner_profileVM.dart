import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_owner_state.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';

class OwnerProfileVM extends ChangeNotifier {
  bool _showMyInfo = true;
  List<User> users = [];
  List<OwnerPropertyList> ownerUnits = [];

  bool get showMyInfo => _showMyInfo;

  void fetchData() {
    users = GlobalUserState.instance.getUsers();
    ownerUnits = GlobalOwnerState.instance.getOwnerData();
  }

  void updateShowMyInfo(bool value) {
    _showMyInfo = value;
    notifyListeners();
  }
}
