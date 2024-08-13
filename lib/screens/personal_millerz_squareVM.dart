import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/provider/global_unitByMonth_state.dart';
import 'package:mana_mana_app/repository/property_list.dart';

class personalMillerzSquareVM extends ChangeNotifier {
  static final personalMillerzSquareVM _instance = personalMillerzSquareVM._internal();
  final PropertyListRepository ownerPropertyList_repository = PropertyListRepository();
  List<OwnerPropertyList> ownerUnits = [];
  List<singleUnitByMonth> unitByMonth = [];
  List<String> yearItems = [];
  List<String> monthItems = [];
  bool isLoading = true;
  static bool _isInitialized = false;
  
  factory personalMillerzSquareVM() {
    if (!_isInitialized) {
      _isInitialized = true;
      _instance.fetchData();
    }
    return _instance;
  }
  personalMillerzSquareVM._internal();

  Future<void> fetchData() async {
    unitByMonth = await ownerPropertyList_repository.getUnitByMonth();
    if (unitByMonth.isNotEmpty){
    GlobalUnitByMonthState.instance.setUnitByMonthData(unitByMonth);
    yearItems = unitByMonth.map((item) => item.iyear.toString()).toSet().toList();   
    monthItems = unitByMonth.where((item) => item.iyear == DateTime.now().year).map((item) => item.imonth.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));   
    }else{
      yearItems = ['-'];
      monthItems = ['-'];
    }     
    notifyListeners();
    isLoading = false;
    print('run fetchData');
    await Future.delayed(const Duration(seconds: 1)); 
    
    // notifyListeners();
    _isInitialized = false;
    
  }
}