import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/repository/property_list.dart';

class PropertyDetailVM extends ChangeNotifier {
  List<Map<String, dynamic>> locationByMonth = [];
  String locationRoad = '';
  String property = '';

  String? selectedType;
  String? selectedUnitNo;
  List<OwnerPropertyList> ownerData = [];
  List<SingleUnitByMonth> unitByMonth = [];
  List<String> yearItems = [];
  List<String> monthItems = [];
  List<String> typeItems = [];
  String? selectedYearValue;
  String? selectedMonthValue;
  int unitLatestMonth = 0;
  int unitLatestYear = 0;
  bool isLoading = true;
  String selectedValue = '';
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;
  // List<singleUnitByMonth> selectedUnitBlc = [];
  var selectedUnitBlc;
  var selectedUnitPro;
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();

  Future<void> fetchData(List<Map<String, dynamic>> newLocationByMonth) async {
    locationByMonth = newLocationByMonth;
    property = locationByMonth[0]['location'];

    switch (property.toUpperCase()) {
      case "EXPRESSIONZ":
        locationRoad = "@ Jalan Tun Razak";
        break;
      case "CEYLONZ":
        locationRoad = "@ Persiaran Raja Chulan";
        break;
      case "SCARLETZ":
        locationRoad = "@ Jalan Yap Kwan Seng";
        break;
      case "MILLERZ":
        locationRoad = "@ Old Klang Road";
        break;
      case "MOSSAZ":
        locationRoad = "@ Empire City";
        break;
      case "PAXTONZ":
        locationRoad = "@ Empire City";
        break;
      default:
        locationRoad = "";
        break;
    }
    ownerData = await ownerPropertyListRepository.getOwnerUnit();
    if (ownerData.isNotEmpty) {
      selectedType = ownerData
          .firstWhere((data) => data.location == property,
              orElse: () => OwnerPropertyList(type: '', unitno: ''))
          .type
          .toString();
      selectedUnitNo = ownerData
          .firstWhere((data) => data.location == property,
              orElse: () => OwnerPropertyList(type: '', unitno: ''))
          .unitno
          .toString();
    }

    typeItems = ownerData
        .where((types) => types.location == property)
        .map((types) => '${types.type} (${types.unitno})')
        .toList();
    if (typeItems.isNotEmpty) {
      selectedType =
          selectedType == '' ? typeItems.first.split(" (")[0] : selectedType;
      selectedUnitNo = selectedUnitNo == ''
          ? typeItems.first.split(" (")[1].replaceAll(")", "")
          : selectedUnitNo;
    }

    unitByMonth = await ownerPropertyListRepository.getUnitByMonth();
    var filteredYears = unitByMonth
        .where((unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo)
        .map((unit) => unit.iyear ?? 0)
        .toList();
    if (filteredYears.isNotEmpty) {
      unitLatestYear = filteredYears
          .reduce((value, element) => value > element ? value : element);
    } else {
      unitLatestYear = 0;
    }
    var filteredMonths = unitByMonth
        .where((unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.iyear == unitLatestYear)
        .map((unit) => unit.imonth ?? 0)
        .toList();

    if (filteredMonths.isNotEmpty) {
      unitLatestMonth = filteredMonths
          .reduce((value, element) => value > element ? value : element);
    } else {
      unitLatestMonth = 0; // or handle accordingly
    }

    selectedUnitBlc = unitByMonth.firstWhere(
        (unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.imonth == unitLatestMonth &&
            unit.iyear == unitLatestYear &&
            unit.stranscode == 'OWNBAL',
        orElse: () => SingleUnitByMonth(total: 0.00));

    selectedUnitPro = unitByMonth.firstWhere(
        (unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.imonth == unitLatestMonth &&
            unit.iyear == unitLatestYear &&
            unit.stranscode == 'NOPROF',
        orElse: () => SingleUnitByMonth(total: 0.00));

    if (unitByMonth.isNotEmpty) {
      yearItems = unitByMonth
          .map((item) => item.iyear.toString())
          .toSet()
          .toList()
        ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      monthItems = unitByMonth
          // .where((item) => item.iyear == int.parse(yearItems.first))
          .map((item) => item.imonth.toString())
          .toSet()
          .toList()
        ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

      // yearItems = unitByMonth.map((item) => item.iyear.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      // monthItems = unitByMonth.where((item) => item.iyear == DateTime.now().year).map((item) => item.imonth.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      selectedMonthValue = monthItems.isNotEmpty
          ? monthItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
          : '';
      selectedYearValue = yearItems.isNotEmpty
          ? yearItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
          : '';
    } else {
      yearItems = ['-'];
      monthItems = ['-'];
    }

    isLoading = false;
    notifyListeners();
  }

  void updateSelectedTypeUnit(
      String newSelectedType, String newSelectedUnitNo) {
    selectedType = newSelectedType;
    selectedUnitNo = newSelectedUnitNo;
    selectedUnitBlc = unitByMonth.firstWhere(
        (unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.imonth == unitLatestMonth &&
            unit.iyear == unitLatestYear &&
            unit.stranscode == 'OWNBAL',
        orElse: () => SingleUnitByMonth(total: 0.00));

    selectedUnitPro = unitByMonth.firstWhere(
        (unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.imonth == unitLatestMonth &&
            unit.iyear == unitLatestYear &&
            unit.stranscode == 'NOPROF',
        orElse: () => SingleUnitByMonth(total: 0.00));
    notifyListeners();
  }

  void updateSelectedYear(String newSelectedYear) {
    selectedYearValue = newSelectedYear;
    notifyListeners();
  }

  void updateSelectedMonth(String newSelectedMonth) {
    selectedMonthValue = newSelectedMonth;
    notifyListeners();
  }

  Future<void> downloadPdfStatement(BuildContext context) async {
    _isDownloading = true;
    notifyListeners();
    // print(property);
    // print(selectedYearValue);
    // print(selectedMonthValue);
    // print(selectedType);
    // print(selectedUnitNo);
    await ownerPropertyListRepository.downloadPdfStatement(context, property,
        selectedYearValue, selectedMonthValue, selectedType, selectedUnitNo);
        _isDownloading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    fetchData(locationByMonth);
    notifyListeners();
  }
}
