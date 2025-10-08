import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/screens/Profile/View/room_details.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/screens/Profile/Widget/quantity_controller.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'dart:convert';
import 'dart:typed_data';

class SelectDateRoom extends StatefulWidget {
  final String ownedLocation;
  final String ownedUnitNo;
  final String location;
  final String state;
  final double points;

  const SelectDateRoom({
    Key? key,
    required this.ownedLocation,
    required this.ownedUnitNo,
    required this.location,
    required this.state,
    required this.points,
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

  static double calculateTotalPoints(
      RoomType room, int quantity, int duration) {
    return room.roomTypePoints * quantity * duration;
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

  RoomType? _selectedRoom;
  String? _selectedRoomId;
  late OwnerProfileVM _vm;

  // 🆕 Track the last fetched parameters to detect staleness
  DateTime? _lastFetchedStart;
  DateTime? _lastFetchedEnd;
  int? _lastFetchedQuantity;
  bool _hasPendingChanges = false;

  @override
  void initState() {
    super.initState();

    _focusedDay = DateTime.now().add(const Duration(days: 7));
    _selectedDay = null;
    
    // Initialize VM and load data
    _vm = context.read<OwnerProfileVM>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // First load blocked dates
    await _fetchBlockedDates();

    // Then load initial room types with default dates
    final defaultStart = DateTime.now().add(const Duration(days: 7));
    final defaultEnd = defaultStart.add(const Duration(days: 1));

    setState(() {
      _rangeStart = defaultStart;
      _rangeEnd = defaultEnd;
    });

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
        arrivalDate: defaultStart,
        departureDate: defaultEnd,
      ),
    ]);
  }

  String sanitizeRoomTypeName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    final firstToken = s.split(RegExp(r'\s+'))[0];

    final isAllCaps = RegExp(r'^[A-Z]+$').hasMatch(firstToken);
    if (isAllCaps && firstToken.length >= 2 && firstToken.length <= 5) {
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
        _selectedRoom = null;
        _selectedRoomId = null;
        _hasPendingChanges = false;
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
        _hasPendingChanges = true; // 🆕 Mark as pending
      } else {
        _rangeStart = start;
        _rangeEnd = end;
        _hasPendingChanges = true; // 🆕 Mark as pending
      }
    });

    // Only fetch if BOTH dates are selected
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
        
        // If we don't have a selection and rooms are available, auto-select first affordable room
        if (_selectedRoomId == null && _vm.roomTypes.isNotEmpty) {
          final affordableRoom = _vm.roomTypes.firstWhere(
            (room) => isRoomAffordable(room, end.difference(start).inDays, _selectedQuantity),
            orElse: () => RoomType(roomTypeName: '', roomTypePoints: 0, pic: ''),
          );
          
          if (affordableRoom.roomTypeName.isNotEmpty) {
            _selectedRoom = affordableRoom;
            _selectedRoomId = affordableRoom.roomTypeName;
          }
        } else if (_selectedRoomId != null) {
          _restoreRoomSelection();
        }
      });
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

    final matchingRoom = _vm.roomTypes.firstWhere(
      (room) => room.roomTypeName == _selectedRoomId,
      orElse: () => RoomType(roomTypeName: '', roomTypePoints: 0, pic: ''),
    );

    if (matchingRoom.roomTypeName.isNotEmpty) {
      final duration = (_rangeStart != null && _rangeEnd != null)
          ? _rangeEnd!.difference(_rangeStart!).inDays
          : 1;

      final isAffordable = isRoomAffordable(
        matchingRoom,
        duration,
        _selectedQuantity.toInt(),
      );

      if (isAffordable) {
        setState(() {
          _selectedRoom = matchingRoom;
        });
      } else {
        setState(() {
          _selectedRoom = null;
          _selectedRoomId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Previously selected room is no longer affordable with current quantity/dates. Please select again.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      setState(() {
        _selectedRoom = null;
        _selectedRoomId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Previously selected room is no longer available. Please select again.',
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
    final bool hasRange = _rangeStart != null && _rangeEnd != null;
    final totalPoints = hasRange
        ? room.roomTypePoints
        : room.roomTypePoints * (duration == 0 ? 1 : duration) * quantity;
    return totalPoints <= userPoints;
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

  Timer? _fetchDebounce;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerProfileVM>();

    final int totalPoints =
        (_selectedRoom != null) ? _selectedRoom!.roomTypePoints.toInt() : 0;

    final String formattedPoints = NumberFormat('#,###').format(totalPoints);

    // 🆕 Check if data is stale
    final bool dataIsStale = _isDataStale();

    if (_isLoadingBlockedDates) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Select Date and Room'),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Date and Room'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                const Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    '* The purple circle indicates the peak hour',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
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
                      defaultBuilder: (context, day, focusedDay) {
                        if (_isGreyDay(day)) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
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
                // Points Balance
                Padding(
                  padding: const EdgeInsets.all(18),
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

                const Padding(
                  padding: EdgeInsets.only(left: 18, bottom: 8),
                  child: Text(
                    'Available Room Types',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Room Types Grid
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
                    final displayName = sanitizeRoomTypeName(room.roomTypeName);
                    final userPoints = vm.UserPointBalance.isNotEmpty
                        ? vm.UserPointBalance.first.redemptionBalancePoints
                        : 0;
                    final bool hasRange =
                        _rangeStart != null && _rangeEnd != null;
                    final totalRoomPoints = hasRange
                        ? room.roomTypePoints
                        : room.roomTypePoints *
                            (duration == 0 ? 1 : duration) *
                            _selectedQuantity;
                    final affordable = totalRoomPoints <= userPoints;

                    return RoomTypeTile(
                      key: ValueKey(
                          displayName), // stable key preserves tile state and cache
                      room: room,
                      displayName: displayName,
                      isSelected: displayName == (_selectedRoomId ?? ''),
                      enabled: affordable,
                      onTap: affordable
                          ? () {
                              setState(() {
                                _selectedRoom = room;
                                // store sanitized display name to match UI
                                _selectedRoomId = displayName;
                              });
                            }
                          : null,
                    );
                  },
                ),

                // Quantity Controller
                Column(
                  children: [
                    Text(
                      'Number of Rooms',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: QuantityController(
                        onChanged: (val) {
                          setState(() {
                            _selectedQuantity = val;
                            _hasPendingChanges = true; // 🆕 Mark as pending
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
                // Next Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: TextButton(
                      onPressed: dataIsStale
                          ? null
                          : _onNextPressed, // 🆕 Disable if stale
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          dataIsStale
                              ? Colors.grey.shade300
                              : const Color(0xFF3E51FF),
                        ),
                        fixedSize:
                            MaterialStateProperty.all(const Size(300, 40)),
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
    return SizedBox(
      width: 160,
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
    final points = widget.points;

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
              color: const Color(0xFF3E51FF),
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

    // Double-check affordability before proceeding
    final effectiveDuration = _rangeEnd!.difference(_rangeStart!).inDays;
    if (!isRoomAffordable(
      _selectedRoom!,
      effectiveDuration,
      _selectedQuantity,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected room is not affordable with current points'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
    final double userPointsBalance = ownerVM.UserPointBalance.isNotEmpty
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

  Widget _buildRoomTypeCard(
    BuildContext context,
    String roomType,
    double point,
    String imagePath, {
    required bool isSelected,
  }) {
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
              height: 180,
              fit: BoxFit.cover,
            ),
            if (isSelected)
              Container(
                width: double.infinity,
                height: 180,
                color: Colors.black.withOpacity(0.6),
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
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRoom = room;
          _selectedRoomId = room.roomTypeName;
        });
      },
      child: _buildRoomTypeCard(
        context,
        room.roomTypeName,
        room.roomTypePoints,
        room.pic,
        isSelected: isSelected,
      ),
    );
  }
}

/// Small tile widget that decodes base64 once and preserves state.
/// Use ValueKey(displayName) when instantiating so Flutter keeps the state.
class RoomTypeTile extends StatefulWidget {
  final RoomType room;
  final String displayName; // already sanitized if you use sanitize
  final bool isSelected;
  final VoidCallback? onTap;
  final bool enabled;
  final Function(RoomType room)? onRoomSelected; // Added callback for room selection

  const RoomTypeTile({
    Key? key,
    required this.room,
    required this.displayName,
    this.isSelected = false,
    this.onTap,
    this.enabled = true,
    this.onRoomSelected, // New parameter
  }) : super(key: key);

  @override
  State<RoomTypeTile> createState() => _RoomTypeTileState();
}

class _RoomTypeTileState extends State<RoomTypeTile>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _bytes;
  bool _decoding = false;

  @override
  void initState() {
    super.initState();
    _decodeOnce();
  }

  Future<void> _decodeOnce() async {
    if (_bytes != null || _decoding) return;
    _decoding = true;

    try {
      final pic = widget.room.pic ?? '';
      if (pic.isEmpty) {
        _bytes = null;
      } else if (pic.startsWith('data:image')) {
        // data URI: parse
        final data = Uri.parse(pic).data;
        _bytes = data?.contentAsBytes();
      } else {
        _bytes = base64Decode(pic);
      }
    } catch (e) {
      // decoding failed -> leave _bytes null
      _bytes = null;
    } finally {
      if (mounted) {
        _decoding = false;
        setState(() {});
      }
    }
  }

  @override
  bool get wantKeepAlive => true; // keep decoded bytes alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    // Use the cached _bytes (or placeholder)
    final imageWidget = _bytes != null
        ? Image.memory(
            _bytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
          )
        : Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey[300],
            child: const Center(
              child:
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            ),
          );

    // Make selection highlight smooth with AnimatedOpacity or AnimatedContainer
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: imageWidget,
              ),
            ),
            // selection overlay
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: widget.isSelected ? 0.55 : 0.0,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // bottom gradient + name + points
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
                      widget.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${NumberFormat("#,###").format(widget.room.roomTypePoints)} points',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // disabled overlay when not affordable
            if (!widget.enabled)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
