import 'dart:async';
import 'dart:ffi' hide Size;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/screens/Profile/View/room_details.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/screens/Profile/Widget/roomtype_card.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class SelectDateRoom extends StatefulWidget {
  final String ownedLocation;
  final String ownedUnitNo;
  final String location;
  final String state;
  final double points;
  // Optional: control the border width of the range start / end decorations
  final double rangeStartBorderWidth;
  final double rangeEndBorderWidth;

  const SelectDateRoom({
    Key? key,
    required this.ownedLocation,
    required this.ownedUnitNo,
    required this.location,
    required this.state,
    required this.points,
    this.rangeStartBorderWidth = 1.0,
    this.rangeEndBorderWidth = 1.0,
  }) : super(key: key);

  static int getUserPointsBalance(OwnerProfileVM vm) {
    final points = vm.UserPointBalance.isNotEmpty
        ? vm.UserPointBalance.first.redemptionBalancePoints
        : 0;
    // final redemptionPoints = vm.UserPointBalance.isNotEmpty
    //     ? vm.UserPointBalance.first.redemptionPoints
    //     : 0;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);
    // final formattedRedemptionPoints = formatter.format(redemptionPoints);
    return formattedPoints.isNotEmpty
        ? int.parse(formattedPoints.replaceAll(',', ''))
        : 0;
  }

  static String getFormatUserPointsBalance(OwnerProfileVM vm) {
    final formatter = NumberFormat('#,###');
    return formatter.format(getUserPointsBalance(vm));
  }

  @override
  _SelectDateRoomState createState() => _SelectDateRoomState();
}

class _SelectDateRoomState extends State<SelectDateRoom> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _selectedQuantity = 1;
  List<CalendarBlockedDate> _blockedDates = [];
  bool _isLoadingBlockedDates = true;
  bool _isLoadingRoomTypes = false;
  bool _hasPendingChanges = false;

  // Track the last fetched parameters to detect staleness
  DateTime? _lastFetchedStart;
  DateTime? _lastFetchedEnd;
  int? _lastFetchedQuantity;

  RoomType? _selectedRoom;
  String? _selectedRoomId;
  late OwnerProfileVM _vm;
  Timer? _fetchDebounce;

  @override
  void initState() {
    super.initState();

    _focusedDay = DateTime.now().add(const Duration(days: 7));
    _selectedDay = null;

    // Initialize VM and load data
    _vm = context.read<OwnerProfileVM>();
    _fetchDebounce = null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    // First load blocked dates
    await _fetchBlockedDates();

    // Load required data
    await Future.wait([
      _vm.ensureAllLocationDataLoaded(),
      _vm.fetchRedemptionBalancePoints(
        location: widget.ownedLocation,
        unitNo: widget.ownedUnitNo,
      ),
      _vm.fetchRoomTypes(
        state: widget.state,
        bookingLocationName: widget.location,
        rooms: _selectedQuantity,
        arrivalDate: DateTime.now().add(const Duration(days: 7)),
        departureDate: DateTime.now().add(const Duration(days: 8)),
      ),
    ]);
  }

  int getNumBedroomsFromRoomTypeName(String roomTypeName) {
    final regex = RegExp(r'(\d+)', caseSensitive: false);
    final match = regex.firstMatch(roomTypeName);
    if (match != null && match.groupCount >= 1) {
      return int.parse(match.group(1) ?? '1');
    }
    return 1; // Default to 1 bedroom if not specified
  }

  String sanitizeRoomTypeName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    final firstToken = s.split(RegExp(r'\s+'))[0];

    // If the first token starts with a digit (eg. "22M" building code), strip it
    if (RegExp(r'^\d').hasMatch(firstToken)) {
      return s.substring(firstToken.length).trim();
    }

    final isAllCaps = RegExp(r'^[A-Z]+$').hasMatch(firstToken);
    // Only strip very short all-caps tokens (likely codes/abbreviations).
    // Keep longer words (e.g., 'RUBY', 'CORAL') which are meaningful descriptors.
    if (isAllCaps && firstToken.length >= 2 && firstToken.length <= 3) {
      return s.substring(firstToken.length).trim();
    }

    return s;
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
        _hasPendingChanges = false;
        // Keep the room selection
      });
      return;
    }

    if (start != null && end != null) {
      bool hasBlocked = false;
      for (DateTime d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        if (_isBlackoutDay(d)) {
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
        _hasPendingChanges = true;
      } else {
        _rangeStart = start;
        _rangeEnd = end;
        _hasPendingChanges = true;
        // Don't clear room selection, it will be validated in _restoreRoomSelection
      }
    }); // Only fetch if BOTH dates are selected
    if (start != null && end != null) {
      _fetchDebounce?.cancel();
      _fetchDebounce = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _fetchRoomTypesAndMaintainSelection();
      });
    }
  }

  // Enhanced room type fetching with immediate selection availability
  Future<void> _fetchRoomTypesAndMaintainSelection() async {
    // If no dates selected, use default range
    final start = _rangeStart ?? DateTime.now().add(const Duration(days: 7));
    final end = _rangeEnd ?? start.add(const Duration(days: 1));

    setState(() => _isLoadingRoomTypes = true);

    try {
      await _vm.fetchRoomTypes(
        state: widget.state,
        bookingLocationName: widget.location,
        rooms: _selectedQuantity,
        arrivalDate: _toDateOnly(start),
        departureDate: _toDateOnly(end),
      );

      // Update tracking parameters
      setState(() {
        _lastFetchedStart = start;
        _lastFetchedEnd = end;
        _lastFetchedQuantity = _selectedQuantity;
        _hasPendingChanges = false;
      });

      // Try to maintain the current room selection if exists
      if (_selectedRoomId != null) {
        _restoreRoomSelection();
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch room types: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update room prices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoomTypes = false);
      }
    }
  }

  void _restoreRoomSelection() {
    if (_selectedRoomId == null) return;

    // First find the room in current available rooms
    final matchingRoom = _vm.roomTypes.firstWhere(
      (room) => room.roomTypeName == _selectedRoomId,
      orElse: () => RoomType(
          roomTypeName: '',
          roomTypePoints: 0,
          pic: '',
          pic2: '',
          pic3: '',
          pic4: '',
          pic5: '',
          numberOfPax: 1),
    );

    if (matchingRoom.roomTypeName.isEmpty) {
      // Room is not available for these dates
      setState(() {
        _selectedRoom = null;
        _selectedRoomId = null;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //       'Selected room is not available for these dates.',
      //     ),
      //     backgroundColor: Colors.orange,
      //   ),
      // );
      return;
    }

    // Room is available, check if user has enough points
    final isAffordable = isRoomAffordable(
      matchingRoom,
      1, // duration doesn't affect points
      1, // quantity doesn't affect points
    );

    if (isAffordable) {
      // Room is available and affordable, keep the selection
      setState(() {
        _selectedRoom = matchingRoom;
      });
    } else {
      // Room is available but not affordable
      setState(() {
        _selectedRoom = null;
        _selectedRoomId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Insufficient points for the selected room.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
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

  bool isRoomAffordable(RoomType room, int duration, int quantity) {
    final userPoints = _vm.UserPointBalance.isNotEmpty
        ? _vm.UserPointBalance.first.redemptionBalancePoints
        : 0;

    // Simply compare the room's points with user's points
    // No multiplication by duration or quantity as points are fixed per room
    return room.roomTypePoints <= userPoints;
  }

  // 🆕 Check if current selection matches last fetch
  bool _isDataStale() {
    if (_rangeStart == null || _rangeEnd == null) return false;

    return _lastFetchedStart == null ||
        _lastFetchedEnd == null ||
        _lastFetchedQuantity == null ||
        !isSameDay(_lastFetchedStart!, _rangeStart!) ||
        !isSameDay(_lastFetchedEnd!, _rangeEnd!) ||
        _lastFetchedQuantity != _selectedQuantity ||
        _hasPendingChanges;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerProfileVM>();

    // Calculate total points: room points × quantity
    final String formattedPoints = _selectedRoom != null
        ? NumberFormat('#,###').format(_selectedRoom!.roomTypePoints)
        : '0';

    // 🆕 Check if data is stale
    final bool dataIsStale = _isDataStale();

    if (_isLoadingBlockedDates) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Select Date and Room',
                style: TextStyle(
                  color: const Color(0xFF606060),
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(18),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Select Date and Room',
              style: TextStyle(
                color: const Color(0xFF606060),
                fontFamily: 'outfit',
                fontSize: ResponsiveSize.text(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF606060),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 18),
                          child: Text(
                            '* The yellow icon indicates the peak dates',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFFCF00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
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
                      final sevenDaysFromNow =
                          today.add(const Duration(days: 7));

                      if (day.isBefore(sevenDaysFromNow)) return false;
                      if (_isBlackoutDay(day)) return false;

                      return true;
                    },
                    calendarBuilders: CalendarBuilders(
                      disabledBuilder: (context, day, focusedDay) {
                        if (_isBlackoutDay(day)) {
                          final color = Colors.black;

                          bool isStart = _blockedDates.any(
                            (bd) =>
                                (bd.contentType.toLowerCase() == "black") &&
                                isSameDay(bd.dateFrom, day),
                          );
                          bool isEnd = _blockedDates.any(
                            (bd) =>
                                (bd.contentType.toLowerCase() == "black") &&
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
                                      style:
                                          const TextStyle(color: Colors.white),
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
                      // Custom smaller widgets for range start / end so we can scale them down
                      rangeStartBuilder: (context, day, focusedDay) {
                        final size = ResponsiveSize.scaleWidth(28);
                        // Center the marker so it lines up vertically with other day widgets
                        return Center(
                          child: SizedBox(
                            width: size,
                            height: size,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF606060),
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      rangeHighlightBuilder: (context, day, isWithinRange) {
                        if (!isWithinRange) return null;

                        final bandHeight = ResponsiveSize.scaleHeight(14);
                        final bandColor = Colors.grey.shade300;

                        // Single-day range: small centered connector under the
                        // marker so start/end markers remain visible.
                        if (_rangeStart != null &&
                            _rangeEnd != null &&
                            isSameDay(day, _rangeStart!) &&
                            isSameDay(day, _rangeEnd!)) {
                          return Center(
                            child: Container(
                              width: ResponsiveSize.scaleWidth(28),
                              height: bandHeight,
                              decoration: BoxDecoration(
                                color: bandColor,
                                // borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          );
                        }

                        // Start cell: connector anchored to the right so it begins
                        // immediately after the start marker.
                        if (_rangeStart != null &&
                            isSameDay(day, _rangeStart!)) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: ResponsiveSize.scaleWidth(20),
                              height: bandHeight,
                              decoration: BoxDecoration(
                                color: bandColor,
                                // borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          );
                        }

                        // End cell: connector anchored to the left so it ends
                        // immediately before the end marker.
                        if (_rangeEnd != null && isSameDay(day, _rangeEnd!)) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: ResponsiveSize.scaleWidth(20),
                              height: bandHeight,
                              decoration: BoxDecoration(
                                color: bandColor,
                                // borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          );
                        }

                        // Intermediate days: full-width thin band between anchors.
                        return Center(
                          child: Container(
                            width: double.infinity,
                            height: bandHeight,
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: bandColor,
                              // borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      },

                      rangeEndBuilder: (context, day, focusedDay) {
                        final size = ResponsiveSize.scaleWidth(28);
                        return Center(
                          child: SizedBox(
                            width: size,
                            height: size,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF606060),
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        if (_isGreyDay(day)) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            width: ResponsiveSize.scaleWidth(30),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCF00),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month'
                    },
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onDaySelected: _onDaySelected,
                    rangeStartDay: _rangeStart,
                    onRangeSelected: _onRangeSelected,
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    rangeEndDay: _rangeEnd,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF606060),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(1),
                        shape: BoxShape.circle,
                      ),
                      // Keep the start/end CELL decorations transparent so the
                      // custom small markers from the builders appear above the
                      // band. The within-range cells will show a full-height
                      // light-gray band (the "bridge").
                      rangeStartDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      // We render a thin connector via rangeHighlightBuilder.
                      // Keep the default within-range cell decoration transparent
                      // so it doesn't paint a full-height band behind our thin
                      // connector. Avoid borderRadius here to prevent animation
                      // tween conflicts with circular selected decorations.
                      withinRangeDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      // Deprecated / extra highlight color kept in sync with
                      // withinRangeDecoration for compatibility.
                      rangeHighlightColor: Colors.grey.shade300,
                    ),
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  ),
                ),

                const SizedBox(height: 10),
                // Check-in / Check-out Cards
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSize.scaleWidth(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateCard('Check-In', _rangeStart),
                      _buildDateCard('Check-Out', _rangeEnd),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveSize.scaleHeight(10)),
                // Points Balance
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSize.scaleWidth(18),
                      vertical: ResponsiveSize.scaleHeight(5)),
                  child: _buildPointsAndQuantity(vm),
                ),

                // 🆕 Stale Data Warning
                if (dataIsStale && _rangeStart != null && _rangeEnd != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Room prices are updating...',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: ResponsiveSize.scaleHeight(26)),
                const Padding(
                  padding: EdgeInsets.only(left: 18, bottom: 8),
                  child: Text(
                    'Available Room Types',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Room Types List
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: vm.roomTypes.length,
                  itemBuilder: (context, index) {
                    final room = vm.roomTypes[index];
                    final displayName = sanitizeRoomTypeName(room.roomTypeName);
                    final numberOfPax = room.numberOfPax;
                    final numBedRooms =
                        getNumBedroomsFromRoomTypeName(displayName);
                    final start = _rangeStart ??
                        DateTime.now().add(const Duration(days: 7));
                    final end = _rangeEnd ?? start.add(const Duration(days: 1));

                    return RoomtypeCard(
                      key: ValueKey(displayName),
                      roomType: room,
                      displayName: displayName,
                      isSelected: displayName == (_selectedRoomId ?? ''),
                      enabled: true,
                      startDate: start,
                      endDate: end,
                      quantity: _selectedQuantity,
                      numberofPax: numberOfPax,
                      numBedrooms: numBedRooms,
                      checkAffordable: (room, duration) {
                        final userPoints = vm.UserPointBalance.isNotEmpty
                            ? vm.UserPointBalance.first.redemptionBalancePoints
                            : 0;
                        final totalPoints =
                            room.roomTypePoints * _selectedQuantity;
                        return totalPoints <= userPoints;
                      },
                      onSelect: (selectedRoom) {
                        setState(() {
                          _selectedRoom = selectedRoom;
                          _selectedRoomId = selectedRoom != null
                              ? sanitizeRoomTypeName(selectedRoom.roomTypeName)
                              : null;
                        });
                      },
                      onQuantityChanged: (val) {
                        setState(() {
                          _selectedQuantity = val;
                          _hasPendingChanges = true;
                        });

                        // Only fetch if both dates are selected
                        if (_rangeStart != null && _rangeEnd != null) {
                          _fetchDebounce?.cancel();
                          _fetchDebounce = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              if (mounted && _selectedQuantity == val) {
                                _fetchRoomTypesAndMaintainSelection();
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ),

                // const SizedBox(height: 5),
                // Total Points
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSize.scaleWidth(15),
                    vertical: ResponsiveSize.scaleHeight(1),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // color: Color.fromARGB(255, 236, 247, 255),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveSize.scaleWidth(12)),
                      child: Row(
                        children: [
                          Text(
                            'Number of Rooms Selected:  ',
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(10),
                              fontFamily: 'outfit',
                              fontWeight: FontWeight.w400,
                              // color: const Color(0xFF606060),
                            ),
                          ),
                          Text('$_selectedQuantity',
                              style: TextStyle(
                                fontSize: ResponsiveSize.text(12),
                                fontFamily: 'outfit',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              )),
                          Spacer(),
                          Text(
                            'Total: ',
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(12),
                              fontFamily: 'outfit',
                              fontWeight: FontWeight.w400,
                              // color: const Color(0xFF606060),
                            ),
                          ),
                          Text(
                            '$formattedPoints points',
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(12),
                              fontFamily: 'outfit',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Next Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: TextButton(
                      onPressed: dataIsStale
                          ? null
                          : _onNextPressed, // 🆕 Disable if stale
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          dataIsStale
                              ? Colors.grey.shade300
                              : const Color(0xFF606060),
                        ),
                        fixedSize: MaterialStateProperty.all(Size(300, 40)),
                      ),
                      child: Text(
                        dataIsStale ? 'Updating Prices...' : 'Next',
                        style: TextStyle(
                          color:
                              dataIsStale ? Colors.grey.shade600 : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveSize.scaleHeight(20),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoadingRoomTypes)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Updating room availability...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime? date) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      width: 160,
      child: Card(
        color: Colors.white,
        shadowColor: Colors.transparent,
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
                  fontSize: 13,
                  color: Color(0xFF606060),
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
    final points = widget.points;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(255, 236, 247, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Point Balance:  ',
            style: TextStyle(
              fontSize: ResponsiveSize.text(13),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formattedPoints,
            style: TextStyle(
              color: const Color(0xFF606060),
              fontSize: ResponsiveSize.text(15),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Enhanced with stale data check
  void _onNextPressed() async {
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

    // 🆕 If data is stale, force refresh first
    if (_isDataStale()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating room prices, please wait...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      await _fetchRoomTypesAndMaintainSelection();

      // After refresh, check again if it's still stale (in case of error)
      if (_isDataStale()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update prices. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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

    // Check if total points = 0
    if (_selectedRoom!.roomTypePoints == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot proceed with 0 points. Please select a valid room.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simply check if user has enough points for the room
    if (!isRoomAffordable(_selectedRoom!, 1, 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient points for this room.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
    final userPointsBalance = ownerVM.UserPointBalance.isNotEmpty
        ? ownerVM.UserPointBalance.first.redemptionBalancePoints
        : 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _vm,
          child: RoomDetails(
            room: _selectedRoom!,
            checkIn: _rangeStart,
            checkOut: _rangeEnd,
            quantity: _selectedQuantity,
            userPointsBalance: userPointsBalance,
            ownerLocation: widget.ownedLocation,
            ownerUnitNo: widget.ownedUnitNo,
            bookingLocationName: widget.location,
          ),
        ),
      ),
    );
  }
}
