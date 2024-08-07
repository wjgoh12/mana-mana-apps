import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';

class GlobalUnitByMonthState {
  static final GlobalUnitByMonthState instance = GlobalUnitByMonthState._internal();
  
  factory GlobalUnitByMonthState() {
    return instance;
  }
  
  GlobalUnitByMonthState._internal();
  
  List<singleUnitByMonth> _UnitByMonthData = [];
  
  void setUnitByMonthData(List<singleUnitByMonth> UnitByMonthData) {
    _UnitByMonthData = UnitByMonthData;
  }
  
  List<singleUnitByMonth> getUnitByMonthData() {
    return _UnitByMonthData;
  }
}