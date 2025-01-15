import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';

class PropertyDetailVM extends ChangeNotifier {
  List<Map<String, dynamic>> locationByMonth = [];
  String locationRoad = '';
  String property = '';

  String? selectedType;
  String? selectedUnitNo;
  List<OwnerPropertyList> ownerData = [];
  List<SingleUnitByMonth> unitByMonth = [];
  List<User> _users = [];
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
  bool _isMonthLoadng = false;
  bool _isDateLoading = false;
  bool get isMonthLoadng => _isMonthLoadng;
  bool get isDownloading => _isDownloading;
  bool get isDateLoading => _isDateLoading;
  // List<singleUnitByMonth> selectedUnitBlc = [];
  var selectedUnitBlc;
  var selectedUnitPro;
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();
  final UserRepository userRepository = UserRepository();

  Future<void> fetchData(List<Map<String, dynamic>> newLocationByMonth) async {
    locationByMonth = newLocationByMonth;
    _users = await userRepository.getUsers();
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
    // unitByMonth = [
    //   SingleUnitByMonth(
    //       total: 4200.31,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'NOPROF',
    //       sunitno: '45-99.99',
    //       imonth: 1,
    //       iyear: 2025),
    //   SingleUnitByMonth(
    //       total: 1842.01,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'OWNBAL',
    //       sunitno: '45-99.99',
    //       imonth: 1,
    //       iyear: 2025),
    //   SingleUnitByMonth(
    //       total: 4200.31,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'NOPROF',
    //       sunitno: '45-99.99',
    //       imonth: 5,
    //       iyear: 2024),
    //   SingleUnitByMonth(
    //       total: 1842.01,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'OWNBAL',
    //       sunitno: '45-99.99',
    //       imonth: 5,
    //       iyear: 2024),
    //   SingleUnitByMonth(
    //       total: 4200.31,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'NOPROF',
    //       sunitno: '45-99.99',
    //       imonth: 6,
    //       iyear: 2024),
    //   SingleUnitByMonth(
    //       total: 1842.01,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'OWNBAL',
    //       sunitno: '45-99.99',
    //       imonth: 6,
    //       iyear: 2024),
    //   SingleUnitByMonth(
    //       total: 1234.0,
    //       slocation: 'SCARLETZ',
    //       stype: 'D',
    //       stranscode: 'NOPROF',
    //       sunitno: '45-99.99',
    //       imonth: 12,
    //       iyear: 2024),
    //   SingleUnitByMonth(
    //       total: 1842.01,
    //       slocation: 'SCARLETZ',
    //       stype: 'Premium 2 Bedroom',
    //       stranscode: 'OWNBAL',
    //       sunitno: '2000-2100-55',
    //       imonth: 1,
    //       iyear: 2025),
    //   SingleUnitByMonth(
    //       total: 1234.0,
    //       slocation: 'SCARLETZ',
    //       stype: 'Premium 2 Bedroom',
    //       stranscode: 'NOPROF',
    //       sunitno: '2000-2100-55',
    //       imonth: 1,
    //       iyear: 2025),
    //   SingleUnitByMonth(
    //       total: 1842.01,
    //       slocation: 'SCARLETZ',
    //       stype: 'Premium 2 Bedroom',
    //       stranscode: 'OWNBAL',
    //       sunitno: '2000-2100-55',
    //       imonth: 11,
    //       iyear: 2024),
    //   SingleUnitByMonth(
    //       total: 1234.0,
    //       slocation: 'SCARLETZ',
    //       stype: 'Premium 2 Bedroom',
    //       stranscode: 'NOPROF',
    //       sunitno: '2000-2100-55',
    //       imonth: 11,
    //       iyear: 2024),
    // ];
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
          .where((item) =>
              item.slocation == property &&
              item.stype == selectedType &&
              item.sunitno == selectedUnitNo)
          .map((item) => item.iyear.toString())
          .toSet()
          .toList()
        ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      selectedYearValue = yearItems.isNotEmpty
          ? yearItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
          : '';
      monthItems = unitByMonth
          .where((item) =>
              item.iyear.toString() == selectedYearValue &&
              item.slocation == property &&
              item.stype == selectedType &&
              item.sunitno == selectedUnitNo)
          .map((item) => item.imonth.toString())
          .toSet()
          .toList()
        ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      selectedMonthValue = monthItems.isNotEmpty
          ? monthItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
          : '';
      // yearItems = unitByMonth.map((item) => item.iyear.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      // monthItems = unitByMonth.where((item) => item.iyear == DateTime.now().year).map((item) => item.imonth.toString()).toSet().toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    } else {
      yearItems = ['-'];
      monthItems = ['-'];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateSelectedTypeUnit(
      String newSelectedType, String newSelectedUnitNo) async {
    _isDateLoading = true;
    notifyListeners();
    selectedType = newSelectedType;
    selectedUnitNo = newSelectedUnitNo;
    yearItems = unitByMonth
        .where((item) =>
            item.slocation == property &&
            item.stype == selectedType &&
            item.sunitno == selectedUnitNo)
        .map((item) => item.iyear.toString())
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    selectedYearValue = yearItems.isNotEmpty
        ? yearItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
        : '';
    monthItems = unitByMonth
        .where((item) =>
            item.iyear.toString() == selectedYearValue &&
            item.slocation == property &&
            item.stype == selectedType &&
            item.sunitno == selectedUnitNo)
        .map((item) => item.imonth.toString())
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    selectedMonthValue = monthItems.isNotEmpty
        ? monthItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
        : '';
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
    await Future.delayed(const Duration(milliseconds: 1000));
    _isDateLoading = false;
    notifyListeners();
  }

  Future<void> updateSelectedYear(String newSelectedYear) async {
    _isMonthLoadng = true;
    notifyListeners();
    // monthItems = ['0','1','2','3','4','5','6','7','8','9','10','11','12'];
    selectedYearValue = newSelectedYear;
    monthItems = unitByMonth
        .where((item) =>
            item.iyear.toString() == selectedYearValue &&
            item.slocation == property &&
            item.stype == selectedType &&
            item.sunitno == selectedUnitNo)
        .map((item) => item.imonth.toString())
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    selectedMonthValue = monthItems.isNotEmpty
        ? monthItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
        : '';
    // selectedYearValue = newSelectedYear;
    await Future.delayed(const Duration(milliseconds: 1000));
    _isMonthLoadng = false;

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
    await ownerPropertyListRepository.downloadPdfStatement(
        context,
        property,
        selectedYearValue,
        selectedMonthValue,
        selectedType,
        selectedUnitNo,
        _users);
    _isDownloading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    fetchData(locationByMonth);
    notifyListeners();
  }
}
