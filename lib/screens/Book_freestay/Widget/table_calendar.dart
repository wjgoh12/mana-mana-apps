import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalendar extends StatefulWidget {
  @override
  _TableCalendarState createState() => _TableCalendarState();
}

class _TableCalendarState extends State<TableCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TableCalendar(),
    );
  }
}
