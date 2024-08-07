import 'package:mana_mana_app/model/user_model.dart';

class GlobalUserState {
  static final GlobalUserState instance = GlobalUserState._internal();
  
  factory GlobalUserState() {
    return instance;
  }
  
  GlobalUserState._internal();
  
  List<User> _users = [];
  
  void setUsers(List<User> users) {
    _users = users;
  }
  
  List<User> getUsers() {
    return _users;
  }
}
