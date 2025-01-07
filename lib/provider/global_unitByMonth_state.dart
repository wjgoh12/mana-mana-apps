import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';

class GlobalUnitByMonthState {
  static final GlobalUnitByMonthState instance = GlobalUnitByMonthState._internal();
  
  factory GlobalUnitByMonthState() {
    return instance;
  }
  
  GlobalUnitByMonthState._internal();
  
  List<SingleUnitByMonth> unitByMonthData = [];
  
  void setUnitByMonthData(List<SingleUnitByMonth> unitByMonthDataList) {
    unitByMonthData = unitByMonthDataList;
  }
  
  List<SingleUnitByMonth> getUnitByMonthData() {
    return unitByMonthData;
  }
}