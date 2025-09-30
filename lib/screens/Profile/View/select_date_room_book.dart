import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/screens/Profile/View/room_details.dart';
import 'package:mana_mana_app/screens/Profile/View/room_details_book.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/screens/Profile/Widget/quantity_controller.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';

class SelectDateRoomBook extends StatefulWidget {
  final String ownedLocation;
  final String ownedUnitNo;
  final String location;
  final String state;

  const SelectDateRoomBook({
    Key? key,
    required this.ownedLocation,
    required this.ownedUnitNo,
    required this.location,
    required this.state,
  }) : super(key: key);

  static int getUserPointsBalance(OwnerProfileVM vm) {
    final points = vm.UserPointBalance.isNotEmpty
        ? vm.UserPointBalance.first.redemptionBalancePoints
        : 0;
    final redemptionPoints = vm.UserPointBalance.isNotEmpty
        ? vm.UserPointBalance.first.redemptionPoints
        : 0;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);
    final formattedRedemptionPoints = formatter.format(redemptionPoints);
    return formattedPoints.isNotEmpty
        ? int.parse(formattedPoints.replaceAll(',', ''))
        : 0;
  }

  static String getFormatUserPointsBalance(OwnerProfileVM vm) {
    final formatter = NumberFormat('#,###');
    return formatter.format(getUserPointsBalance(vm));
  }

  static double calculateTotalPoints(
      RoomType room, int quantity, int duration) {
    return room.roomTypePoints * quantity * duration;
  }

  @override
  _SelectDateRoomBookState createState() => _SelectDateRoomBookState();
}

class _SelectDateRoomBookState extends State<SelectDateRoomBook> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _selectedQuantity = 1;
  List<CalendarBlockedDate> _blockedDates = [];
  bool _isLoadingBlockedDates = true;

  RoomType? _selectedRoom;
  String? _selectedRoomId;
  late OwnerProfileVM _vm;

  // Smart unit selection variables
  UnitAvailablePoint? _currentSelectedUnit;
  List<UnitAvailablePoint> _sortedUnits = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 SelectDateRoomBook initState started');

    _focusedDay = DateTime.now().add(const Duration(days: 7));
    _selectedDay = null;
    _fetchBlockedDates();

    _vm = context.read<OwnerProfileVM>();

    // Fetch data in order, similar to property_redemption
    Future.microtask(() async {
      await _vm.fetchData(); // Ensure user data is loaded first

      // Sort and initialize units after points are loaded
      final sortedUnits = [..._vm.unitAvailablePoints]
          .where((unit) => unit.redemptionBalancePoints > 0)
          .toList()
        ..sort((a, b) =>
            b.redemptionBalancePoints.compareTo(a.redemptionBalancePoints));

      if (sortedUnits.isNotEmpty) {
        setState(() {
          _currentSelectedUnit = sortedUnits.first;
          _sortedUnits = sortedUnits;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('📱 Post frame callback started');
      // First, fetch all unit available points for smart selection
      debugPrint('🔄 Fetching user available points...');
      await _vm.fetchUserAvailablePoints();
      // await _vm.fetchRedemptionBalancePointsBook(
      //     location: _vm.unitAvailablePoints.first.location,
      //     unitNo: _vm.unitAvailablePoints.first.unitNo);
      debugPrint('✅ User available points fetched');

      // Initialize smart selection with lowest points unit
      _initializeSmartUnitSelection();

      // Then fetch room types
      debugPrint('🏨 Checking if room types need to be fetched...');
      if (_vm.roomTypes.isEmpty) {
        debugPrint('🔄 Fetching room types...');
        await _vm.fetchRoomTypes(
          state: widget.state,
          bookingLocationName: widget.location,
          rooms: _selectedQuantity,
          arrivalDate: _focusedDay,
          departureDate: _focusedDay?.add(const Duration(days: 1)),
        );
      }
    });
  }

  // Initialize smart unit selection - start with lowest points unit
  void _initializeSmartUnitSelection() {
    debugPrint("🔹 Starting smart unit selection initialization");

    if (_vm.unitAvailablePoints.isEmpty) {
      debugPrint("⚠️ No available units found");
      return;
    }

    // Sort units by redemptionBalancePoints (ascending - lowest first)
    _sortedUnits = [..._vm.unitAvailablePoints]..sort((a, b) =>
        a.redemptionBalancePoints.compareTo(b.redemptionBalancePoints));

    // Start with the lowest points unit
    _currentSelectedUnit = _sortedUnits.first;

    // Only fetch redemption points if we have a valid unit
    if (_currentSelectedUnit != null &&
        _currentSelectedUnit!.location.isNotEmpty &&
        _currentSelectedUnit!.unitNo.isNotEmpty) {
      debugPrint(
          '📍 Initial unit selected: ${_currentSelectedUnit!.location} - ${_currentSelectedUnit!.unitNo}');
      _vm.fetchRedemptionBalancePointsBook(
          location: _currentSelectedUnit!.location,
          unitNo: _currentSelectedUnit!.unitNo);
    }

    // Update UserPointBalance
    _updateUserPointBalanceForCurrentUnit();

    setState(() {});
  }

  // Switch to a suitable unit that can afford the required points
  bool _switchToSuitableUnit(double requiredPoints) {
    debugPrint('\n=== Switching Unit Debug ===');
    debugPrint("🔄 Attempting to switch to unit with sufficient points");
    debugPrint("Required points: $requiredPoints");
    debugPrint("Available units: ${_sortedUnits.length}");

    // Print all sorted units for debugging
    _sortedUnits.forEach((unit) {
      debugPrint(
          '💳 Unit ${unit.location} - ${unit.unitNo}: ${unit.redemptionBalancePoints} points');
    });

    if (_sortedUnits.isEmpty) {
      debugPrint("❌ No units available for switching");
      return false;
    }

    // Find the unit with least points that can afford the required points
    UnitAvailablePoint? suitableUnit;
    for (final unit in _sortedUnits) {
      if (unit.redemptionBalancePoints >= requiredPoints) {
        suitableUnit = unit;
        break;
      }
    }

    if (suitableUnit != null) {
      final previousUnit = _currentSelectedUnit;
      _currentSelectedUnit = suitableUnit;

      // Update UserPointBalance to reflect new selected unit
      _updateUserPointBalanceForCurrentUnit();

      // Show notification if unit changed
      if (previousUnit != null &&
          (previousUnit.location != suitableUnit.location ||
              previousUnit.unitNo != suitableUnit.unitNo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Switched to ${suitableUnit.location} - ${suitableUnit.unitNo} for sufficient points (${NumberFormat('#,###').format(suitableUnit.redemptionBalancePoints)} points)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {});
      return true;
    }

    return false;
  }

  // Update UserPointBalance to reflect current selected unit
  void _updateUserPointBalanceForCurrentUnit() {
    if (_currentSelectedUnit == null) {
      debugPrint('⚠️ No current unit selected');
      return;
    }

    debugPrint(
        'Updating points for unit: ${_currentSelectedUnit!.location} - ${_currentSelectedUnit!.unitNo}');
    debugPrint(
        'Available points: ${_currentSelectedUnit!.redemptionBalancePoints}');

    debugPrint('=== Updating User Point Balance ===');
    debugPrint('🏢 Unit Location: ${_currentSelectedUnit!.location}');
    debugPrint('📍 Unit Number: ${_currentSelectedUnit!.unitNo}');
    debugPrint(
        '💰 Balance Points: ${_currentSelectedUnit!.redemptionBalancePoints}');

    debugPrint(
        '🔄 Updating points for unit: ${_currentSelectedUnit!.location} - ${_currentSelectedUnit!.unitNo}');
    debugPrint(
        '💰 Balance points: ${_currentSelectedUnit!.redemptionBalancePoints}');
    debugPrint('💎 Total points: ${_currentSelectedUnit!.redemptionPoints}');

    // Create a temporary balance object for the current unit
    final tempBalance = {
      'location': _currentSelectedUnit!.location.trim(),
      'unitNo': _currentSelectedUnit!.unitNo.trim(),
      'redemptionBalancePoints': _currentSelectedUnit!.redemptionBalancePoints,
      'redemptionPoints': _currentSelectedUnit!.redemptionPoints,
    };

    _vm.UserPointBalance.clear();
    _vm.UserPointBalance.add(tempBalance);
  }

  // Check if any unit can afford the required points
  bool _canAnyUnitAfford(double requiredPoints) {
    return _sortedUnits
        .any((unit) => unit.redemptionBalancePoints >= requiredPoints);
  }

  Future<void> _fetchBlockedDates() async {
    if (_blockedDates.isNotEmpty) return;

    setState(() => _isLoadingBlockedDates = true);
    try {
      final repo = RedemptionRepository();
      final res = await repo.getCalendarBlockedDates();
      final filteredDates = repo.filterBlockedDatesForState(res, widget.state);

      setState(() {
        _blockedDates = filteredDates;
        _isLoadingBlockedDates = false;
      });
    } catch (e) {
      debugPrint("Failed to fetch blocked dates: $e");
      setState(() => _isLoadingBlockedDates = false);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    if (start == null && end == null) {
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
        _selectedDay = null;
        _selectedQuantity = 1;
        _selectedRoom = null;
        _selectedRoomId = null;
      });
      return;
    }

    if (start != null && end != null) {
      bool hasBlocked = false;
      for (DateTime d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        if (_isBlackoutDay(d) || _isGreyDay(d)) {
          hasBlocked = true;
          break;
        }
      }

      if (hasBlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected range includes blocked dates. Please choose another range.',
            ),
            backgroundColor: Color.fromARGB(255, 203, 46, 46),
          ),
        );
        return;
      }
    }

    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
      _selectedDay = null;

      if (start != null && end == null) {
        _rangeStart = start;
        _rangeEnd = null;
      } else {
        _rangeStart = start;
        _rangeEnd = end;
      }
    });

    _fetchDebounce?.cancel();
    _fetchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _fetchRoomTypesAndMaintainSelection();
    });
  }

  Future<void> _fetchRoomTypesAndMaintainSelection() async {
    await _vm.fetchRoomTypes(
      state: widget.state,
      bookingLocationName: widget.location,
      rooms: _selectedQuantity,
      arrivalDate: _rangeStart != null ? _toDateOnly(_rangeStart!) : null,
      departureDate: _rangeEnd != null ? _toDateOnly(_rangeEnd!) : null,
    );

    if (_selectedRoomId != null) {
      _restoreRoomSelection();
    }
  }

  void _restoreRoomSelection() {
    if (_selectedRoomId == null) return;

    final matchingRoom = _vm.roomTypes.firstWhere(
      (room) => room.roomTypeName == _selectedRoomId,
      orElse: () => RoomType(roomTypeName: '', roomTypePoints: 0, pic: ''),
    );

    if (matchingRoom.roomTypeName.isNotEmpty) {
      setState(() {
        _selectedRoom = matchingRoom;
      });
    }
  }

  @override
  void dispose() {
    _fetchDebounce?.cancel();
    super.dispose();
  }

  int get duration {
    if (_rangeStart != null && _rangeEnd != null) {
      return _rangeEnd!.difference(_rangeStart!).inDays;
    }
    return 0;
  }

  DateTime _toDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isBlackoutDay(DateTime day) {
    final d = _toDateOnly(day);
    return _blockedDates.any(
      (bd) =>
          bd.contentType.toLowerCase() == "black" &&
          !d.isBefore(_toDateOnly(bd.dateFrom)) &&
          !d.isAfter(_toDateOnly(bd.dateTo)),
    );
  }

  bool _isGreyDay(DateTime day) {
    final d = _toDateOnly(day);
    return _blockedDates.any(
      (bd) =>
          bd.contentType.toLowerCase() == "grey" &&
          !d.isBefore(_toDateOnly(bd.dateFrom)) &&
          !d.isAfter(_toDateOnly(bd.dateTo)),
    );
  }

  DateTime getInitialFocusedDay() {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(Duration(days: 7));

    bool hasAvailableDayThisMonth = false;
    DateTime firstOfMonth = DateTime(today.year, today.month, 1);
    DateTime lastOfMonth = DateTime(today.year, today.month + 1, 0);

    for (DateTime d = firstOfMonth;
        d.isBefore(lastOfMonth.add(Duration(days: 1)));
        d = d.add(Duration(days: 1))) {
      if (_isDayEnabled(d)) {
        hasAvailableDayThisMonth = true;
        break;
      }
    }

    if (hasAvailableDayThisMonth) {
      return today;
    }

    return sevenDaysFromNow;
  }

  bool _isDayEnabled(DateTime day) {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(Duration(days: 7));
    return day.isAfter(sevenDaysFromNow) || isSameDay(day, sevenDaysFromNow);
  }

  // bool isRoomAffordable(RoomType room, int duration, int quantity) {
  //   final userPoints = _currentSelectedUnit?.redemptionBalancePoints ?? 0;
  //   final bool hasRange = _rangeStart != null && _rangeEnd != null;
  //   final totalPoints = hasRange
  //       ? room.roomTypePoints
  //       : room.roomTypePoints * (duration == 0 ? 1 : duration) * quantity;
  //   return totalPoints <= userPoints;
  // }

  Timer? _fetchDebounce;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerProfileVM>();
    int effectiveDuration = (_rangeStart != null && _rangeEnd != null)
        ? _rangeEnd!.difference(_rangeStart!).inDays
        : 1;

    final double totalPoints =
        (_selectedRoom != null) ? _selectedRoom!.roomTypePoints : 0;

    final String formattedPoints = NumberFormat('#,###').format(totalPoints);

    if (_isLoadingBlockedDates) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Make a Booking'),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Make a Booking'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay ?? getInitialFocusedDay(),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                enabledDayPredicate: (day) {
                  final today = DateTime.now();
                  final sevenDaysFromNow = today.add(const Duration(days: 7));
                  if (day.isBefore(sevenDaysFromNow)) return false;
                  if (_isBlackoutDay(day)) return false;
                  if (_isGreyDay(day)) return false;
                  return true;
                },
                calendarBuilders: CalendarBuilders(
                  disabledBuilder: (context, day, focusedDay) {
                    if (_isBlackoutDay(day) || _isGreyDay(day)) {
                      final color =
                          _isBlackoutDay(day) ? Colors.black : Colors.grey;

                      bool isStart = _blockedDates.any(
                        (bd) =>
                            (bd.contentType.toLowerCase() ==
                                (_isBlackoutDay(day) ? "black" : "grey")) &&
                            isSameDay(bd.dateFrom, day),
                      );
                      bool isEnd = _blockedDates.any(
                        (bd) =>
                            (bd.contentType.toLowerCase() ==
                                (_isBlackoutDay(day) ? "black" : "grey")) &&
                            isSameDay(bd.dateTo, day),
                      );

                      if (isStart || isEnd) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: color.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    return null;
                  },
                ),
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: _onDaySelected,
                rangeStartDay: _rangeStart,
                onRangeSelected: _onRangeSelected,
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                rangeEndDay: _rangeEnd,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF3E51FF),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                  rangeStartDecoration: BoxDecoration(
                    color: const Color(0xFF3E51FF).withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: const Color(0xFF3E51FF).withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                ),
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              ),
            ),

            const SizedBox(height: 10),
            // Check-in / Check-out Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateCard('Check-In', _rangeStart),
                  _buildDateCard('Check-Out', _rangeEnd),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Points Balance & Quantity
            Padding(
              padding: const EdgeInsets.all(18),
              child: _buildPointsAndQuantity(vm),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 18, bottom: 8),
              child: Text(
                'Available Room Types',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Room Types Grid with Smart Selection Logic
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 200,
              ),
              itemCount: vm.roomTypes.length,
              itemBuilder: (context, index) {
                final room = vm.roomTypes[index];
                final bool hasRange = _rangeStart != null && _rangeEnd != null;
                final totalRoomPoints = hasRange
                    ? room.roomTypePoints
                    : room.roomTypePoints *
                        (duration == 0 ? 1 : duration) *
                        _selectedQuantity;

                return _buildRoomCard(
                  room,
                  isSelected: room.roomTypeName == _selectedRoomId,
                );
              },
            ),

            // Quantity Controller
            Column(
              children: [
                Text(
                  'Number of Rooms',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Center(
                  child: QuantityController(
                    onChanged: (val) {
                      setState(() {
                        _selectedQuantity = val;
                      });

                      _fetchDebounce?.cancel();
                      _fetchDebounce = Timer(
                        const Duration(milliseconds: 500),
                        () {
                          if (mounted && _selectedQuantity == val) {
                            _fetchRoomTypesAndMaintainSelection();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Total Points
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: Text(
                  'Total: $formattedPoints points',
                  style: TextStyle(
                    fontSize: ResponsiveSize.text(16),
                    fontFamily: 'outfit',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E51FF),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Submit Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: TextButton(
                  onPressed: _onNextPressed,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF3E51FF),
                    ),
                    fixedSize: MaterialStateProperty.all(const Size(300, 40)),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime? date) {
    return SizedBox(
      width: 180,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                date != null
                    ? DateFormat('EEE, MMM d, yyyy').format(date)
                    : '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3E51FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsAndQuantity(OwnerProfileVM vm) {
    // Use current selected unit's points instead of UserPointBalance
    final points = _currentSelectedUnit?.redemptionBalancePoints ?? 0;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 247, 255),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Point Balance:',
                style: TextStyle(
                  fontSize: ResponsiveSize.text(13),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedPoints,
                style: TextStyle(
                  color: const Color(0xFF3E51FF),
                  fontSize: ResponsiveSize.text(15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Show which unit is being used
          // if (_currentSelectedUnit != null) ...[
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 8.0),
          //     child: Container(
          //       padding: const EdgeInsets.all(12),
          //       decoration: BoxDecoration(
          //         color: Colors.blue.shade50,
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Row(
          //         children: [
          //           const Icon(Icons.home, color: Colors.blue),
          //           const SizedBox(width: 8),
          //           Expanded(
          //             child: Text(
          //               "Using Unit: ${_currentSelectedUnit!.location} - ${_currentSelectedUnit!.unitNo}\n",
          //               style: const TextStyle(
          //                   fontSize: 14, fontWeight: FontWeight.w500),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  void _onNextPressed() {
    // Check if dates are selected
    if (_rangeStart == null || _rangeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if room is selected
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate total points needed
    _rangeEnd!
        .difference(_rangeStart!)
        .inDays; // Calculate duration without redefining the variable
    final totalPointsNeeded = _selectedRoom!.roomTypePoints;

    // Check if we have enough points
    final availablePoints = _currentSelectedUnit?.redemptionBalancePoints ?? 0;
    if (totalPointsNeeded > availablePoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Insufficient points. Need $totalPointsNeeded points but only have $availablePoints available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (totalPointsNeeded == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid room selection!.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate required points and ensure we have suitable unit
    final effectiveDuration = _rangeEnd!.difference(_rangeStart!).inDays;
    final bool hasRange = _rangeStart != null && _rangeEnd != null;
    final double totalPoints = hasRange
        ? _selectedRoom!.roomTypePoints
        : _selectedRoom!.roomTypePoints * effectiveDuration * _selectedQuantity;

    if (!_switchToSuitableUnit(totalPoints)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No unit has sufficient points for this booking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double userPointsBalance =
        _currentSelectedUnit?.redemptionBalancePoints ?? 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _vm,
          child: RoomDetailsBook(
            room: _selectedRoom!,
            checkIn: _rangeStart,
            checkOut: _rangeEnd,
            quantity: _selectedQuantity,
            userPointsBalance: userPointsBalance,
            ownerLocation: _currentSelectedUnit?.location ?? '',
            ownerUnitNo: _currentSelectedUnit?.unitNo ?? '',
            bookingLocationName: widget.location,
            isBookingMode: true, // Set to true for booking mode
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTypeCard(
    BuildContext context,
    String roomType,
    double point,
    String imagePath, {
    required bool isSelected,
  }) {
    debugPrint(
        "🏨 Building room type card: $roomType (Points: $point, Selected: $isSelected)");

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(point);

    Uint8List _decodeBase64Image(String base64String) {
      return base64Decode(base64String);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.memory(
              _decodeBase64Image(imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$formattedPoints points',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(RoomType room, {required bool isSelected}) {
    debugPrint('🏨 Building room card for ${room.roomTypeName}');

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? const Color(0xFF3E51FF) : Colors.transparent,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          debugPrint('💭 Room tapped: ${room.roomTypeName}');
          setState(() {
            _selectedRoom = room;
            _selectedRoomId = room.roomTypeName;
          });

          // Optional: only show a warning, but don’t block selection
          final requiredPoints = room.roomTypePoints;
          final availablePoints =
              _currentSelectedUnit?.redemptionBalancePoints ?? 0;

          if (requiredPoints > availablePoints) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This room requires $requiredPoints points but you only have $availablePoints available.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: _buildRoomTypeCard(
          context,
          room.roomTypeName,
          room.roomTypePoints,
          room.pic,
          isSelected: isSelected,
        ),
      ),
    );
  }
}
