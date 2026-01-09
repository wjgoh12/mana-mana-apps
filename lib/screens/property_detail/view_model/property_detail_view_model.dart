import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/owner_property_list.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:mana_mana_app/screens/property_detail/view/annual_statement_pdf_viewer_screen.dart';
import 'package:mana_mana_app/screens/property_detail/view/pdf_viewer_screen.dart';

class PropertyDetailVM extends ChangeNotifier {
  double total = 0.0;
  List<Map<String, dynamic>> locationByMonth = [];
  String locationRoad = '';
  String locationState = '';
  String property = '';

  String? selectedType;
  String? selectedUnitNo;
  String selectedView = 'UnitDetails';
  List<String> propertyOccupancy = [];
  String? _selectedYearValue;
  String? get selectedYearValue => _selectedYearValue;
  List<Map<String, dynamic>> recentActivities = [];

  PropertyDetailVM() {
    _selectedYearValue = null;
  }

  String? selectedMonthValue;
  String? selectedAnnualYearValue;
  int unitLatestMonth = 0;
  int unitLatestYear = 0;
  bool isLoading = true;
  String selectedValue = '';
  bool _isDownloading = false;
  // ignore: non_constant_identifier_names
  bool _annual_isDownloading = false;
  bool _isMonthLoadng = false;
  bool _isDateLoading = false;
  bool get isMonthLoadng => _isMonthLoadng;
  bool get isDownloading => _isDownloading;
  bool get isAnnualDownloading => _annual_isDownloading;
  bool get isDateLoading => _isDateLoading;

  // ignore: prefer_typing_uninitialized_variables
  var selectedUnitBlc;
  // ignore: prefer_typing_uninitialized_variables
  var selectedUnitPro;
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();
  final UserRepository userRepository = UserRepository();
  final GlobalDataManager _globalDataManager = GlobalDataManager();

  List<OwnerPropertyList> get ownerData => _globalDataManager.ownerUnits;
  List<SingleUnitByMonth> get unitByMonth => _globalDataManager.unitByMonth;
  List<User> get users => _globalDataManager.users;
  List<String> get yearItems => _getYearItems();
  List<String> get monthItems => _getMonthItems();
  List<String> get typeItems => _getTypeItems();

  get contractType => null;

  String? selectedProperty;
  String? selectedUnit;

  void updateSelection(String property, String unit) {
    selectedProperty = property;
    selectedUnit = unit;
    notifyListeners();
  }

  Future<void> fetchData(List<Map<String, dynamic>> newLocationByMonth) async {
    isLoading = true;
    notifyListeners();

    await _globalDataManager.initializeData();

    locationByMonth = newLocationByMonth;

    if (locationByMonth.isEmpty) {
      isLoading = false;
      notifyListeners();
      return;
    }

    property = locationByMonth[0]['location'];
    selectedView = 'UnitDetails';
    _setLocationDetails();

    if (ownerData.isNotEmpty &&
        (selectedType == null || selectedUnitNo == null)) {
      final firstUnit = ownerData.firstWhere(
          (data) => data.location == property,
          orElse: () => ownerData.first);

      selectedType = firstUnit.type?.toString() ?? '';
      selectedUnitNo = firstUnit.unitno?.toString() ?? '';
    }

    final typeItemsList = typeItems;
    if (typeItemsList.isNotEmpty &&
        (selectedType == null || selectedType!.isEmpty)) {
      final firstItem = typeItemsList.first;
      selectedType = firstItem.split(" (")[0];
      selectedUnitNo = firstItem.split(" (")[1].replaceAll(")", "");
    }

    _calculateLatestYearMonth();
    _setSelectedUnitData();

    if (_selectedYearValue == null) {
      final yearItemsList = _getYearItems();
      if (yearItemsList.isNotEmpty) {
        _selectedYearValue = yearItemsList.first;
      }
    }

    selectedAnnualYearValue ??= _selectedYearValue;

    _buildRecentActivities();

    isLoading = false;
    notifyListeners();
  }

  void _setLocationDetails() {
    switch (property.toUpperCase()) {
      case "EXPRESSIONZ":
        locationRoad = "Jalan Tun Razak";
        locationState = "Kuala Lumpur";
        break;
      case "CEYLONZ":
        locationRoad = "Persiaran Raja Chulan";
        locationState = "Kuala Lumpur";
        break;
      case "SCARLETZ":
        locationRoad = "Jalan Yap Kwan Seng";
        locationState = "Kuala Lumpur";
        break;
      case "MILLERZ":
        locationRoad = "Old Klang Road";
        locationState = "Old Klang Road";
        break;
      case "MOSSAZ":
        locationRoad = "Empire City";
        locationState = "Empire City";
        break;
      case "PAXTONZ":
        locationRoad = "Empire City";
        locationState = "Empire City";
        break;
      default:
        locationRoad = "";
        locationState = "";
        break;
    }
  }

  void _calculateLatestYearMonth() {
    final currentProperty = selectedProperty ?? property;

    unitLatestYear = 0;
    unitLatestMonth = 0;

    if (selectedType == null || selectedUnitNo == null) {
      return;
    }

    var filteredYears = unitByMonth
        .where((unit) =>
            unit.slocation == currentProperty &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo)
        .map((unit) => unit.iyear ?? 0)
        .toList();

    if (filteredYears.isNotEmpty) {
      unitLatestYear = filteredYears
          .reduce((value, element) => value > element ? value : element);
    }

    var filteredMonths = unitByMonth
        .where((unit) =>
            unit.slocation == currentProperty &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.iyear == unitLatestYear)
        .map((unit) => unit.imonth ?? 0)
        .toList();

    if (filteredMonths.isNotEmpty) {
      unitLatestMonth = filteredMonths
          .reduce((value, element) => value > element ? value : element);
    }
  }

  void _setSelectedUnitData() {
    final currentProperty = selectedProperty ?? property;

    selectedUnitBlc = SingleUnitByMonth(total: 0.00);
    selectedUnitPro = SingleUnitByMonth(total: 0.00);

    if (selectedType != null &&
        selectedUnitNo != null &&
        unitLatestYear > 0 &&
        unitLatestMonth > 0) {
      selectedUnitBlc = unitByMonth.firstWhere(
          (unit) =>
              unit.slocation == currentProperty &&
              unit.stype == selectedType &&
              unit.sunitno == selectedUnitNo &&
              unit.imonth == unitLatestMonth &&
              unit.iyear == unitLatestYear &&
              unit.stranscode == 'OWNBAL',
          orElse: () => SingleUnitByMonth(total: 0.00));

      selectedUnitPro = unitByMonth.firstWhere(
          (unit) =>
              unit.slocation == currentProperty &&
              unit.stype == selectedType &&
              unit.sunitno == selectedUnitNo &&
              unit.imonth == unitLatestMonth &&
              unit.iyear == unitLatestYear &&
              unit.stranscode == 'NOPROF',
          orElse: () => SingleUnitByMonth(total: 0.00));
    }
  }

  List<String> _getYearItems() {
    if (selectedType == null || selectedUnitNo == null) return [];

    final currentProperty = selectedProperty ?? property;
    return unitByMonth
        .where((item) =>
            item.slocation == currentProperty &&
            item.stype == selectedType &&
            item.sunitno == selectedUnitNo)
        .map((item) => item.iyear.toString())
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
  }

  List<String> _getMonthItems() {
    if (selectedType == null ||
        selectedUnitNo == null ||
        _selectedYearValue == null) {
      return [];
    }

    final currentProperty = selectedProperty ?? property;

    return unitByMonth
        .where((item) =>
            item.iyear.toString() == _selectedYearValue &&
            item.slocation == currentProperty &&
            item.stype == selectedType &&
            item.sunitno == selectedUnitNo)
        .map((item) => item.imonth.toString())
        .toSet()
        .toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
  }

  List<String> _getTypeItems() {
    final currentProperty = selectedProperty ?? property;

    final List<String> builtTypeItems = ownerData
        .where((types) => types.location == currentProperty)
        .map((types) => '${types.type} (${types.unitno})')
        .toList();

    final Set<String> seen = <String>{};
    return builtTypeItems.where((e) => seen.add(e)).toList();
  }

  void _buildRecentActivities() {
    recentActivities = unitByMonth.map((item) {
      return {
        "unitNo": item.sunitno,
        "location": item.slocation,
        "month": item.imonth,
        "year": item.iyear,
      };
    }).toList();

    // Sort so most recent is first
    recentActivities.sort((a, b) {
      if (a["year"] == b["year"]) {
        return (b["month"] as int).compareTo(a["month"] as int);
      }
      return (b["year"] as int).compareTo(a["year"] as int);
    });
  }

  Future<void> updateSelectedTypeUnit(
      String newSelectedType, String newSelectedUnitNo) async {
    print(
        '🔄 updateSelectedTypeUnit called: Type=$newSelectedType, Unit=$newSelectedUnitNo, Property=$selectedProperty');
    _isDateLoading = true;

    selectedUnitBlc = SingleUnitByMonth(total: 0.00);
    selectedUnitPro = SingleUnitByMonth(total: 0.00);
    unitLatestYear = 0;
    unitLatestMonth = 0;
    _selectedYearValue = null;
    selectedMonthValue = null;

    print('🧹 Data cleared, notifying listeners...');
    notifyListeners();

    selectedType = newSelectedType;
    selectedUnitNo = newSelectedUnitNo;
    print(
        '📝 New selection set: Type=$selectedType, Unit=$selectedUnitNo, Property=$selectedProperty');

    final yearItemsList = _getYearItems();
    _selectedYearValue = yearItemsList.isNotEmpty
        ? yearItemsList.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
        : null;

    selectedMonthValue = null;

    _calculateLatestYearMonth();

    _setSelectedUnitData();
    print(
        '📊 Final data - Property=$selectedProperty, Type=$selectedType, Unit=$selectedUnitNo, selectedUnitBlc: ${selectedUnitBlc?.total}, selectedUnitPro: ${selectedUnitPro?.total}');

    _isDateLoading = false;
    print('✅ updateSelectedTypeUnit completed, notifying listeners...');
    notifyListeners();
  }

  Future<void> updateSelectedYear(String? newSelectedYear) async {
    if (_selectedYearValue == newSelectedYear) {
      return;
    }

    _isMonthLoadng = true;
    notifyListeners();

    _selectedYearValue = newSelectedYear;

    selectedMonthValue = null;

    _isMonthLoadng = false;
    notifyListeners();
  }

  void updateSelectedAnnualYear(String newSelectedYear) async {
    selectedAnnualYearValue = newSelectedYear;
    notifyListeners();
  }

  void updateSelectedMonth(String? newSelectedMonth) {
    if (selectedMonthValue == newSelectedMonth) {
      return;
    }

    selectedMonthValue = newSelectedMonth;
    notifyListeners();
  }

  void updateSelectedView(String view) {
    selectedView = view;
    notifyListeners();
  }

  Future<void> downloadPdfStatement(BuildContext context) async {
    try {
      _isDownloading = true;
      notifyListeners();

      final bytes = await ownerPropertyListRepository.downloadPdfStatement(
        context,
        property,
        selectedYearValue.toString(),
        selectedMonthValue,
        selectedType.toString(),
        selectedUnitNo.toString(),
        users,
      );

      if (bytes != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerFromMemory(
              property: property,
              year: selectedYearValue,
              month: selectedMonthValue,
              unitType: selectedType,
              unitNo: selectedUnitNo,
              pdfData: bytes,
            ),
          ),
        );
      } else {
        _showErrorDialog(
            context, "Failed to download PDF. Please try again later.");
      }
    } catch (e) {
      _showErrorDialog(context, "Download Failed");
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Download Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> downloadAnnualPdfStatement(BuildContext context) async {
    _annual_isDownloading = true;
    notifyListeners();

    final bytes = await ownerPropertyListRepository.downloadPdfAnnualStatement(
        context,
        property,
        selectedAnnualYearValue,
        selectedType,
        selectedUnitNo,
        users);
    if (bytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnnualStatementPdfViewerFromMemory(
            property: property,
            year: selectedYearValue,
            unitType: selectedType,
            unitNo: selectedUnitNo,
            pdfData: bytes,
          ),
        ),
      );
    }
    _annual_isDownloading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();
    fetchData(locationByMonth);
    notifyListeners();
  }

  Future<void> downloadSpecificPdfStatement(
      BuildContext context, dynamic item) async {
    try {
      _isDownloading = true;
      notifyListeners();

      final bytes = await ownerPropertyListRepository.downloadPdfStatement(
        context,
        item.slocation,
        item.iyear.toString(),
        item.imonth.toString(),
        selectedType.toString(),
        selectedUnitNo.toString(),
        users,
      );
      print('📄 PDF downloaded for Year: ${item.iyear}, Month: ${item.imonth}');

      if (bytes != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerFromMemory(
              property: item.slocation,
              year: item.iyear.toString(),
              month: item.imonth.toString(),
              unitType: selectedType,
              unitNo: selectedUnitNo,
              pdfData: bytes,
            ),
          ),
        );
      } else {
        // Handle null response
        _showErrorDialog(
          context,
          "Unable to retrieve PDF data. Please check your connection and try again.",
        );
      }
    } catch (e) {
      // Handle specific errors
      String errorMessage;
      if (e.toString().contains('NO_RECORD')) {
        errorMessage =
            "No record available for this unit in the selected month.";
      } else if (e.toString().contains('API_ERROR')) {
        errorMessage =
            "Server error: ${e.toString().replaceAll('Exception: API_ERROR: ', '')}";
      } else {
        errorMessage = "Failed to download PDF. Please try again later.";
      }

      _showErrorDialog(context, errorMessage);
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}

final Map<int, String> _monthNumberToName = {
  1: 'Jan',
  2: 'Feb',
  3: 'Mar',
  4: 'Apr',
  5: 'May',
  6: 'Jun',
  7: 'Jul',
  8: 'Aug',
  9: 'Sep',
  10: 'Oct',
  11: 'Nov',
  12: 'Dec',
};

Future<String> getUnitProfitPobMonthYear(List<SingleUnitByMonth> unitByMonth,
    String location, String unitNo, String transCode) async {
  try {
    final filteredRecords = unitByMonth.where((unit) =>
        unit.slocation == location &&
        unit.sunitno == unitNo &&
        unit.stranscode == transCode);

    if (filteredRecords.isEmpty) {
      // fallback to current month/year if no records found
      final now = DateTime.now();
      final monthName = _monthNumberToName[now.month] ?? '';
      return '$monthName ${now.year}';
    }

    // Find the record with the latest year and month
    int latestYear = 0;
    int latestMonth = 0;

    for (var record in filteredRecords) {
      int year = record.iyear ?? 0;
      int month = record.imonth ?? 0;

      if (year > latestYear || (year == latestYear && month > latestMonth)) {
        latestYear = year;
        latestMonth = month;
      }
    }

    final monthName = _monthNumberToName[latestMonth] ?? '';
    return '$monthName $latestYear';
  } catch (e) {
    final now = DateTime.now();
    final monthName = _monthNumberToName[now.month] ?? '';
    return '$monthName ${now.year}';
  }
}
