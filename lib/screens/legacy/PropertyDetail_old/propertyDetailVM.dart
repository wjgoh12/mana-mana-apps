// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/model/owner_property_list.dart';
// import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
// import 'package:mana_mana_app/provider/global_unitByMonth_state.dart';
// import 'package:mana_mana_app/repository/property_list.dart';

// class propertyDetailVM extends ChangeNotifier {
//   static final propertyDetailVM _instance = propertyDetailVM._internal();
//   final PropertyListRepository ownerPropertyList_repository = PropertyListRepository();
//   List<OwnerPropertyList> ownerUnits = [];
//   List<SingleUnitByMonth> unitByMonth = [];
//   List<String> yearItems = [];
//   List<String> monthItems = [];
//   bool isLoading = true;
//   bool loadSelectedMonthValue = false;
//   static bool _isInitialized = false;
//   bool get isDataLoaded => !isLoading && yearItems.isNotEmpty && monthItems.isNotEmpty;

  
//   factory propertyDetailVM() {
//     if (!_isInitialized) {
//       _isInitialized = true;
//       _instance.fetchData();
//     }
//     return _instance;
//   }
//   propertyDetailVM._internal();

//   Future<void> fetchData() async {
//     unitByMonth = await ownerPropertyList_repository.getUnitByMonth();

//     if (unitByMonth.isNotEmpty){
//     GlobalUnitByMonthState.instance.setUnitByMonthData(unitByMonth);
//     yearItems = unitByMonth.map((item) => item.iyear.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));       
//     monthItems = unitByMonth
//     // .where((item) => item.iyear == int.parse(yearItems.first))
//     .map((item) => item.imonth.toString())
//     .toSet()
//     .toList()
//     ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
 
//     // yearItems = unitByMonth.map((item) => item.iyear.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));       
//     // monthItems = unitByMonth.where((item) => item.iyear == DateTime.now().year).map((item) => item.imonth.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a))); 
     
//     }else{
//       yearItems = ['-'];
//       monthItems = ['-'];
//     }     
//     notifyListeners();
//     isLoading = false;
//     print('run fetchData');
//     await Future.delayed(const Duration(seconds: 1)); 
    
//     // notifyListeners();
//     _isInitialized = false;
    
//   }
// }