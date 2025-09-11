import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/screens/Profile/View/room_details.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/screens/Profile/Widget/quantity_controller.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

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

  // 👇 Put the static method here, in the widget class
  static int getUserPointsBalance() {
    // Dummy value for now (replace with real user balance later)
    return 1200;
  }

  static String getFormatUserPointsBalance() {
    final formatter = NumberFormat('#,###');
    return formatter.format(getUserPointsBalance());
  }

  static int calculateTotalPoints(RoomType room, int quantity, int duration) {
    return room.points * quantity * duration;
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
  late OwnerProfileVM _vm;
  OwnerProfileVM get vm => context.watch<OwnerProfileVM>();

  @override
  @override
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchBlockedDates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm = context.read<OwnerProfileVM>();
      _vm.fetchRedemptionBalancePoints(
        location: widget.ownedLocation,
        unitNo: widget.ownedUnitNo,
      );
    });
  }

  Future<void> _fetchBlockedDates() async {
    setState(() => _isLoadingBlockedDates = true);

    try {
      final repo = RedemptionRepository();

      final res = await repo.getCalendarBlockedDates(
        location: widget.location,
        startDate: DateTime.now().toIso8601String(),
        endDate: DateTime.now().add(Duration(days: 365)).toIso8601String(),
      );

      final dates = res.map((e) => CalendarBlockedDate.fromJson(e)).toList();

      // Filter for current state
      final filteredDates = repo.filterBlockedDatesForState(
        dates,
        widget.state,
      );

      setState(() {
        _blockedDates = filteredDates;
        _isLoadingBlockedDates = false;
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch blocked dates: $e");
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
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;

      if (_rangeStart == null || _rangeEnd == null) {
        _selectedQuantity = 1;
      }
    });
    _validateSelectedRoom();
  }

  int get duration {
    if (_rangeStart != null && _rangeEnd != null) {
      return _rangeEnd!.difference(_rangeStart!).inDays;
    }
    return 0;
  }

  //datetime type
  bool _isBlackoutDay(DateTime day) {
    return _blockedDates.any(
      (d) =>
          d.contentType.toLowerCase() == "black" &&
          day.isAfter(d.dateFrom.subtract(Duration(days: 1))) &&
          day.isBefore(d.dateTo.add(Duration(days: 1))),
    );
  }

  bool _isGreyDay(DateTime day) {
    return _blockedDates.any(
      (d) =>
          d.contentType.toLowerCase() == "grey" &&
          day.isAfter(d.dateFrom.subtract(Duration(days: 1))) &&
          day.isBefore(d.dateTo.add(Duration(days: 1))),
    );
  }

  BoxDecoration _rectDeco({Color? color}) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    // borderRadius: const BorderRadius.all(Radius.circular(8)),
  );

  DateTime getInitialFocusedDay() {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(Duration(days: 7));

    // Check if the current month has at least one selectable day
    bool hasAvailableDayThisMonth = false;
    DateTime firstOfMonth = DateTime(today.year, today.month, 1);
    DateTime lastOfMonth = DateTime(today.year, today.month + 1, 0);

    for (
      DateTime d = firstOfMonth;
      d.isBefore(lastOfMonth.add(Duration(days: 1)));
      d = d.add(Duration(days: 1))
    ) {
      if (_isDayEnabled(d)) {
        // helper check
        hasAvailableDayThisMonth = true;
        break;
      }
    }

    // If this month has available dates, keep today.
    if (hasAvailableDayThisMonth) {
      return today;
    }

    // Otherwise, move to 7 days later (which may fall into next month)
    return sevenDaysFromNow;
  }

  bool _isDayEnabled(DateTime day) {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(Duration(days: 7));
    return day.isAfter(sevenDaysFromNow) || isSameDay(day, sevenDaysFromNow);
  }

  bool _isBlockedDay(DateTime day, String type) {
    return _blockedDates.any(
      (d) =>
          d.contentType.toLowerCase() == type &&
          !day.isBefore(d.dateFrom) &&
          !day.isAfter(d.dateTo),
    );
  }

  bool isRoomAffordable(RoomType room, int duration, int quantity) {
    final totalPoints = room.points * duration * quantity;
    return totalPoints <= SelectDateRoom.getUserPointsBalance();
  }

  void _validateSelectedRoom() {
    if (_selectedRoom != null) {
      final stillAffordable = isRoomAffordable(
        _selectedRoom!,
        duration == 0 ? 1 : duration,
        _selectedQuantity,
      );

      if (!stillAffordable) {
        setState(() {
          _selectedRoom = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your previously selected room is no longer affordable. Please select another room.',
            ),
            backgroundColor: Color.fromARGB(255, 203, 46, 46),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);

    if (_isLoadingBlockedDates) {
      // Show loading indicator while blocked dates are being fetched
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
                  // Must be at least 7 days from today
                  if (day.isBefore(sevenDaysFromNow)) return false;

                  // Disable if blackout
                  if (_isBlackoutDay(day)) return false;

                  // Grey days should be disabled (if that's your business rule)
                  if (_isGreyDay(day)) return false;

                  return true;
                },
                calendarBuilders: CalendarBuilders(
                  // For disabled days (black/grey)
                  disabledBuilder: (context, day, focusedDay) {
                    if (_isBlackoutDay(day)) {
                      return _buildBlockedDay(
                        day,
                        Colors.black,
                      ); // Solid black circle
                    } else if (_isGreyDay(day)) {
                      return _buildBlockedDay(
                        day,
                        Colors.grey,
                      ); // Solid grey circle
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
              child: _buildPointsAndQuantity(),
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
                crossAxisCount: 2,
                childAspectRatio: 0.9,
              ),
              itemCount: roomTypes.length,
              itemBuilder: (context, index) {
                final room = roomTypes[index];
                final affordable = isRoomAffordable(
                  room,
                  duration == 0 ? 1 : duration,
                  _selectedQuantity,
                );

                return Opacity(
                  opacity: affordable ? 1 : 0.5,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: _selectedRoom == room
                            ? const Color(0xFF3E51FF)
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (!affordable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Insufficient points for this room. Please choose another.',
                              ),
                              backgroundColor: Color.fromARGB(255, 203, 46, 46),
                            ),
                          );
                          return;
                        }
                        setState(() => _selectedRoom = room);
                      },
                      child: _buildRoomTypeCard(
                        context,
                        room.name,
                        room.points,
                        room.image,
                        isSelected: room == _selectedRoom,
                      ),
                    ),
                  ),
                );
              },
            ),
            Column(
              children: [
                Text(
                  'Quantity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Center(
                  child: QuantityController(
                    onChanged: (val) {
                      setState(() {
                        _selectedQuantity = val;
                      });
                      _validateSelectedRoom();
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
                  'Total: ${_selectedRoom != null ? SelectDateRoom.calculateTotalPoints(_selectedRoom!, _selectedQuantity, duration) : 0} points',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E51FF),
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

  // Helper to build blocked day circle
  Widget _buildBlockedDay(DateTime day, Color color) {
    return Center(
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Helper to build Check-in / Check-out card
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

  // Helper to build points and quantity row
  Widget _buildPointsAndQuantity() {
    final points = vm.UserPointBalance.isNotEmpty
        ? vm.UserPointBalance.first.redemptionBalancePoints
        // or .totalPoints, depends on model
        : 0;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Available Point Balance: ',
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
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  // Next button handler
  void _onNextPressed() {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room before proceeding.'),
          backgroundColor: Color.fromARGB(255, 203, 46, 46),
        ),
      );
      return;
    }
    if (_rangeStart == null || _rangeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Check-in and Check-out dates.'),
          backgroundColor: Color.fromARGB(255, 203, 46, 46),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomDetails(
          room: _selectedRoom!,
          checkIn: _rangeStart,
          checkOut: _rangeEnd,
          nights: duration,
          quantity: _selectedQuantity,
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: isSelected ? Colors.white : const Color(0xFF3E51FF),
        // border: Border.all(
        //   color: isSelected ? const Color(0xFF3E51FF) : Colors.transparent,
        //   width: 2,
        // ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 130,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF3E51FF) : Colors.white,
                  ),
                ),
                Text(
                  '$formattedPoints points',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
