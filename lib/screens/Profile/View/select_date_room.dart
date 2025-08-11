import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // This import is correct, no change needed.

class SelectDateRoom extends StatefulWidget {
  @override
  _SelectDateRoomState createState() => _SelectDateRoomState();
}

class _SelectDateRoomState extends State<SelectDateRoom> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date and Room'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              }, //lock the format to month only
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
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Color(0xFF3E51FF).withOpacity(1),
                  shape: BoxShape.circle,
                  // borderRadius: BorderRadius.circular(8),
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Color(0xFF3E51FF).withOpacity(1),
                  shape: BoxShape.circle,
                  // borderRadius: BorderRadius.circular(8),
                ),
              ),
              // onFormatChanged: (format) {
              //   if (_calendarFormat == format) {
              //     setState(() {
              //       _calendarFormat = format;
              //     });
              //   }
              // },
              onPageChanged: (focusedDay) => {
                _focusedDay = focusedDay,
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
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
                Text('$duration night(s)'),
                Container(
                  width: 150,
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
        ],
      ),
    );
  }
}

Widget _buildRoomTypeCard(BuildContext context, String roomType) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.meeting_room, size: 40, color: Colors.blue),
        const SizedBox(height: 10),
        Text(
          roomType,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
// const SizedBox(height: 20),
          // GridView.count(
          //   crossAxisCount: 2,
          //   shrinkWrap: true,
          //   padding: const EdgeInsets.all(16.0),
          //   children: List.generate(4, (index) {
          //     return Card(
          //       child: InkWell(
          //         onTap: () {
          //           // Handle room selection
          //           // ScaffoldMessenger.of(context).showSnackBar(
          //           //   SnackBar(content: Text('Room ${index + 1} selected')),
          //           // );
          //         },
          //         child: _buildRoomTypeCard(context, 'Garnet Room'),
          //       ),
          //     );
          //   }),
          // ),