import 'package:mana_mana_app/model/OwnerPropertyList.dart';

class GlobalOwnerState {
  static final GlobalOwnerState instance = GlobalOwnerState._internal();
  
  factory GlobalOwnerState() {
    return instance;
  }
  
  GlobalOwnerState._internal();
  
  List<OwnerPropertyList> _ownerData = [];
  
  void setOwnerData(List<OwnerPropertyList> ownerData) {
    _ownerData = ownerData;
  }
  
  List<OwnerPropertyList> getOwnerData() {
    return _ownerData;
  }
}