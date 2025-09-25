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
  const SelectDateRoom({
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

  static int calculateTotalPoints(RoomType room, int quantity, int duration) {
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

  RoomType? _selectedRoom;
  String? _selectedRoomId; // Track by ID to maintain selection across fetches
  late OwnerProfileVM _vm;
  // Avoid listening outside of build. Use `_vm` for actions, and a local
  // `vm = context.watch<OwnerProfileVM>()` inside build for UI updates.

  @override
  void initState() {
    super.initState();

    _focusedDay = DateTime.now().add(const Duration(days: 7));
    _selectedDay = null;
    _fetchBlockedDates();

    _vm = context.read<OwnerProfileVM>();

    // In SelectDateRoom initState(), change this:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        // ALWAYS fetch points for the current unit, don't check if empty
        _vm.fetchRedemptionBalancePoints(
          location: widget.ownedLocation,
          unitNo: widget.ownedUnitNo,
        ),
        _vm.roomTypes.isEmpty
            ? _vm.fetchRoomTypes(
                state: widget.state,
                bookingLocationName: widget.location,
                rooms: _selectedQuantity,
                arrivalDate: _focusedDay,
                departureDate: _focusedDay?.add(const Duration(days: 1)),
              )
            : Future.value(),
      ]);
    });
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

  // New method to fetch room types while maintaining selection
  Future<void> _fetchRoomTypesAndMaintainSelection() async {
    await _vm.fetchRoomTypes(
      state: widget.state,
      bookingLocationName: widget.location,
      rooms: _selectedQuantity,
      arrivalDate: _rangeStart != null ? _toDateOnly(_rangeStart!) : null,
      departureDate: _rangeEnd != null ? _toDateOnly(_rangeEnd!) : null,
    );

    // After fetching, try to restore selection if we had one
    if (_selectedRoomId != null) {
      _restoreRoomSelection();
    }
  }

  // Method to restore room selection after room types are updated
  void _restoreRoomSelection() {
    if (_selectedRoomId == null) return;

    // Find the room in the new list that matches our selected room
    final matchingRoom = _vm.roomTypes.firstWhere(
      (room) => room.roomTypeName == _selectedRoomId,
      orElse: () => RoomType(roomTypeName: '', roomTypePoints: 0, pic: ''),
    );

    if (matchingRoom.roomTypeName.isNotEmpty) {
      // Check if it's still affordable
      final duration = (_rangeStart != null && _rangeEnd != null)
          ? _rangeEnd!.difference(_rangeStart!).inDays
          : 1;

      final isAffordable = isRoomAffordable(
        matchingRoom,
        duration,
        _selectedQuantity,
      );

      if (isAffordable) {
        // Room still exists and is affordable, maintain selection
        setState(() {
          _selectedRoom = matchingRoom;
        });
      } else {
        // Room exists but no longer affordable
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
      // Room no longer exists in the list
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
    // If a date range is selected and we refetched with rooms/dates,
    // assume backend already returns total points for the selection.
    final bool hasRange = _rangeStart != null && _rangeEnd != null;
    final totalPoints = hasRange
        ? room.roomTypePoints
        : room.roomTypePoints * (duration == 0 ? 1 : duration) * quantity;
    return totalPoints <= userPoints;
  }

  Timer? _fetchDebounce;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerProfileVM>();
    int effectiveDuration = (_rangeStart != null && _rangeEnd != null)
        ? _rangeEnd!.difference(_rangeStart!).inDays
        : 1;

    final int totalPoints =
        (_selectedRoom != null) ? _selectedRoom!.roomTypePoints : 0;

    final String formattedPoints = NumberFormat('#,###').format(totalPoints);

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
                final userPoints = vm.UserPointBalance.isNotEmpty
                    ? vm.UserPointBalance.first.redemptionBalancePoints
                    : 0;
                final bool hasRange = _rangeStart != null && _rangeEnd != null;
                final totalRoomPoints = hasRange
                    ? room.roomTypePoints // already includes duration * qty
                    : room.roomTypePoints *
                        (duration == 0 ? 1 : duration) *
                        _selectedQuantity;
                final affordable = totalRoomPoints <= userPoints;

                return affordable
                    ? _buildRoomCard(
                        room,
                        isSelected: room.roomTypeName == _selectedRoomId,
                      )
                    : Opacity(
                        opacity: 0.5,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: room.roomTypeName == _selectedRoomId
                                  ? const Color(0xFF3E51FF)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: null, // Disable tap for unaffordable rooms
                            child: _buildRoomTypeCard(
                              context,
                              room.roomTypeName,
                              room.roomTypePoints,
                              room.pic,
                              isSelected: room.roomTypeName == _selectedRoomId,
                            ),
                          ),
                        ),
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
                        // Keep the room selection ID but clear the room object temporarily
                        // This will allow us to restore it after fetching
                      });

                      // Debounce the room type fetch
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
            // Next Button
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
    final points = vm.UserPointBalance.isNotEmpty
        ? vm.UserPointBalance.first.redemptionBalancePoints
        : 0;

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

  // Enhanced Next button handler with proper validation
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
    final int userPointsBalance = ownerVM.UserPointBalance.isNotEmpty
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
    int point,
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
          setState(() {
            _selectedRoom = room;
            _selectedRoomId = room.roomTypeName; // Store the ID for tracking
          });
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
