import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:mana_mana_app/screens/Property_detail/View/AnnualStatementPdfViewerScreen.dart';
import 'package:mana_mana_app/screens/Property_detail/View/PdfViewerScreen.dart';

class PropertyDetailVM extends ChangeNotifier {
  double total = 0.0;
  List<Map<String, dynamic>> locationByMonth = [];
  String locationRoad = '';
  String locationState = '';
  String property = '';

  String? selectedType;
  String? selectedUnitNo;
  String selectedView =
      'UnitDetails'; // Default to UnitDetails instead of Overview
  List<String> propertyOccupancy =
      []; // List to store PropertyOccupancy objects>
  String? _selectedYearValue; // Don't initialize with any value
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
  bool _annual_isDownloading = false;
  bool _isMonthLoadng = false;
  bool _isDateLoading = false;
  bool get isMonthLoadng => _isMonthLoadng;
  bool get isDownloading => _isDownloading;
  bool get isAnnualDownloading => _annual_isDownloading;
  bool get isDateLoading => _isDateLoading;

  var selectedUnitBlc;
  var selectedUnitPro;
  final PropertyListRepository ownerPropertyListRepository =
      PropertyListRepository();
  final UserRepository userRepository = UserRepository();
  final GlobalDataManager _globalDataManager = GlobalDataManager();

  // Getters that delegate to GlobalDataManager
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
    // print(
    //     '📡 fetchData called - current selection: $selectedType, $selectedUnitNo');
    isLoading = true;
    notifyListeners();

    // Use global data manager to get data (no API calls)
    await _globalDataManager.initializeData();

    locationByMonth = newLocationByMonth;

    if (locationByMonth.isEmpty) {
      isLoading = false;
      notifyListeners();
      return;
    }

    property = locationByMonth[0]['location'];

    // Always default to UnitDetails
    selectedView = 'UnitDetails';

    // Set location details based on property
    _setLocationDetails();

    // Set initial selections from ownerData - Default to first unit only if not already set
    if (ownerData.isNotEmpty &&
        (selectedType == null || selectedUnitNo == null)) {
      print('🔄 Setting initial selection from first unit');
      final firstUnit = ownerData.firstWhere(
          (data) => data.location == property,
          orElse: () => ownerData.first);

      selectedType = firstUnit.type?.toString() ?? '';
      selectedUnitNo = firstUnit.unitno?.toString() ?? '';
      // print('✅ Initial selection set: $selectedType, $selectedUnitNo');
    } else {
      // print(
      //     '⏭️ Skipping initial selection - already set: $selectedType, $selectedUnitNo');
    }

    // Set initial values for dropdowns - Default to first unit if above didn't work
    final typeItemsList = typeItems;
    if (typeItemsList.isNotEmpty &&
        (selectedType == null || selectedType!.isEmpty)) {
      final firstItem = typeItemsList.first;
      selectedType = firstItem.split(" (")[0];
      selectedUnitNo = firstItem.split(" (")[1].replaceAll(")", "");
    }

    // Calculate latest year and month for selected unit
    _calculateLatestYearMonth();

    // Set selected unit data
    _setSelectedUnitData();

    // Auto-select latest year for eStatements
    final yearItemsList = _getYearItems();
    if (yearItemsList.isNotEmpty) {
      _selectedYearValue =
          yearItemsList.first; // First item is latest (sorted descending)
    }

    selectedAnnualYearValue = _selectedYearValue;

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

    // Reset to default values
    unitLatestYear = 0;
    unitLatestMonth = 0;

    // Only calculate if we have valid selections
    if (selectedType == null ||
        selectedUnitNo == null ||
        currentProperty == null) {
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

    // Reset to default values first
    selectedUnitBlc = SingleUnitByMonth(total: 0.00);
    selectedUnitPro = SingleUnitByMonth(total: 0.00);

    // Only set data if we have valid selections AND valid latest year/month
    if (selectedType != null &&
        selectedUnitNo != null &&
        currentProperty != null &&
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
    // print(
    //     '🔄 updateSelectedTypeUnit called: $newSelectedType, $newSelectedUnitNo');
    _isDateLoading = true;

    // Clear all data first
    selectedUnitBlc = SingleUnitByMonth(total: 0.00);
    selectedUnitPro = SingleUnitByMonth(total: 0.00);
    unitLatestYear = 0;
    unitLatestMonth = 0;
    _selectedYearValue = null;
    selectedMonthValue = null;

    // print('🧹 Data cleared, notifying listeners...');
    notifyListeners();

    selectedType = newSelectedType;
    selectedUnitNo = newSelectedUnitNo;
    // print('📝 New selection set: $selectedType, $selectedUnitNo');

    // Update year selection to latest for this unit
    final yearItemsList = _getYearItems();
    _selectedYearValue = yearItemsList.isNotEmpty
        ? yearItemsList.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
        : null;

    // Update month selection
    final monthItemsList = _getMonthItems();
    selectedMonthValue = monthItemsList.isNotEmpty
        ? monthItemsList.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
        : null;

    // Recalculate latest year and month
    _calculateLatestYearMonth();

    // Update selected unit data
    _setSelectedUnitData();
    // print(
    //     '📊 Final data - selectedUnitBlc: ${selectedUnitBlc?.total}, selectedUnitPro: ${selectedUnitPro?.total}');

    _isDateLoading = false;
    // print('✅ updateSelectedTypeUnit completed, notifying listeners...');
    notifyListeners();
  }

  Future<void> updateSelectedYear(String newSelectedYear) async {
    _isMonthLoadng = true;
    notifyListeners();

    _selectedYearValue = newSelectedYear;

    // Try to preserve the current month selection if it exists in the new year
    final monthItemsList = _getMonthItems();
    if (monthItemsList.isNotEmpty) {
      // Check if current month is still available in the new year
      if (selectedMonthValue != null && monthItemsList.contains(selectedMonthValue)) {
        // Keep the current month if it's available in the new year
        // Don't change selectedMonthValue
      } else {
        // Fall back to latest month if current month is not available
        selectedMonthValue = monthItemsList.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b);
      }
    } else {
      selectedMonthValue = null;
    }

    _isMonthLoadng = false;
    notifyListeners();
  }

  void updateSelectedAnnualYear(String newSelectedYear) async {
    selectedAnnualYearValue = newSelectedYear;
    notifyListeners();
  }

  void updateSelectedMonth(String newSelectedMonth) {
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
        selectedYearValue,
        selectedMonthValue,
        selectedType,
        selectedUnitNo,
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
    // Set the specific item data before downloading
    _selectedYearValue = item.iyear.toString();
    selectedMonthValue = item.imonth.toString();

    // Call existing download method
    await downloadPdfStatement(context);
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
