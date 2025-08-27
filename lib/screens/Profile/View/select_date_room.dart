import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/Profile/View/room_details.dart';
import 'package:mana_mana_app/screens/Profile/Widget/quantity_controller.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mana_mana_app/screens/Profile/Data/roomtype.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class SelectDateRoom extends StatefulWidget {
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

  int _getUserPointsBalance() {
    // Dummy value for now (e.g., 12,500 points)
    // Later you can replace this with API call or user model value
    return 12500;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
      if (start != null) print("Range Start: $start");
      if (end != null) print("Range End: $end");
      // print(_rangeEnd);
      // print(_rangeStart);
    });
  }

  int get duration {
    if (_rangeStart != null && _rangeEnd != null) {
      return _rangeEnd!.difference(_rangeStart!).inDays;
    }
    return 0;
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

    for (DateTime d = firstOfMonth;
        d.isBefore(lastOfMonth.add(Duration(days: 1)));
        d = d.add(Duration(days: 1))) {
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

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Select Date and Room'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay ?? getInitialFocusedDay(),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                enabledDayPredicate: (day) {
                  final today = DateTime.now();
                  final sevenDaysFromNow = today.add(Duration(days: 7));
                  return day.isAfter(sevenDaysFromNow) ||
                      isSameDay(day, sevenDaysFromNow);
                },
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
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF3E51FF),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                  rangeStartDecoration: BoxDecoration(
                    color: Color(0xFF3E51FF).withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: Color(0xFF3E51FF).withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                ),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            SizedBox(height: ResponsiveSize.scaleHeight(2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 180,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Check-In'),
                            Text(
                              _rangeStart != null
                                  ? DateFormat('EEE, MMM d, yyyy')
                                      .format(_rangeStart!)
                                  : '-',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3E51FF),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  //const SizedBox(width: 15),
                  // Text('$duration night(s)'),
                  Container(
                    width: 180,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Check-Out'),
                            Text(
                              _rangeEnd != null
                                  ? DateFormat('EEE, MMM d, yyyy')
                                      .format(_rangeEnd!)
                                  : '-',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3E51FF),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Available Point Balance: ',
                    style: TextStyle(
                      fontSize: ResponsiveSize.text(15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_getUserPointsBalance()}',
                    style: TextStyle(
                      color: Color(0xFF3E51FF),
                      fontSize: ResponsiveSize.text(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 18.0,
                bottom: 8,
              ),
              child: Text(
                'Available Room Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
              ),
              itemCount: roomTypes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    onTap: () {
                      if (_rangeStart == null || _rangeEnd == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select both Check-in and Check-out dates before proceeding.',
                            ),
                            backgroundColor: Color.fromARGB(255, 203, 46, 46),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RoomDetails(
                            room: roomTypes[index],
                            checkIn: _rangeStart,
                            checkOut: _rangeEnd,
                            nights: duration,
                            quantity: _selectedQuantity,
                          ),
                        ),
                      );
                    },
                    child: _buildRoomTypeCard(
                      context,
                      roomTypes[index].name,
                      roomTypes[index].points,
                    ),
                  ),
                );
              },
            ),
            Center(
              child: QuantityController(
                onChanged: (val) {
                  setState(() {
                    _selectedQuantity = val; // save selected quantity
                  });
                },
              ),
            ),
            SizedBox(height: ResponsiveSize.scaleHeight(5)),
          ],
        ),
      ),
    );
  }
}

Widget _buildRoomTypeCard(BuildContext context, String roomType, int point) {
  final formatter = NumberFormat('#,###');
  final formattedPoints = formatter.format(point);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: Color(0xFF3E51FF),
    ),
    // padding: const EdgeInsets.all(8.0),
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
            child: Image.asset(
              'assets/images/${roomType.toUpperCase()}.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roomType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${formattedPoints.toString()} points',
                style: const TextStyle(
                  // fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
