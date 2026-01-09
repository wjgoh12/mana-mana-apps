import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final CalendarFormat calendarFormat;
  final List<CalendarBlockedDate> blockedDates;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime?, DateTime?, DateTime) onRangeSelected;
  final void Function(DateTime) onPageChanged;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    this.rangeStart,
    this.rangeEnd,
    required this.calendarFormat,
    required this.blockedDates,
    required this.onDaySelected,
    required this.onRangeSelected,
    required this.onPageChanged,
  });

  DateTime _toDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isBlackoutDay(DateTime day) {
    final d = _toDateOnly(day);
    return blockedDates.any(
      (bd) =>
          bd.contentType.toLowerCase() == "black" &&
          !d.isBefore(_toDateOnly(bd.dateFrom)) &&
          !d.isAfter(_toDateOnly(bd.dateTo)),
    );
  }

  bool _isGreyDay(DateTime day) {
    final d = _toDateOnly(day);
    return blockedDates.any(
      (bd) =>
          bd.contentType.toLowerCase() == "grey" &&
          !d.isBefore(_toDateOnly(bd.dateFrom)) &&
          !d.isAfter(_toDateOnly(bd.dateTo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        enabledDayPredicate: (day) {
          final today = DateTime.now();
          final sevenDaysFromNow = today.add(const Duration(days: 7));

          if (day.isBefore(sevenDaysFromNow)) return false;
          if (_isBlackoutDay(day)) return false;

          return true;
        },
        calendarBuilders: CalendarBuilders(
          disabledBuilder: (context, day, focusedDay) {
            if (_isBlackoutDay(day)) {
              const color = Colors.black;

              bool isStart = blockedDates.any(
                (bd) =>
                    (bd.contentType.toLowerCase() == "black") &&
                    isSameDay(bd.dateFrom, day),
              );
              bool isEnd = blockedDates.any(
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
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
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
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        // ignore: deprecated_member_use
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
          rangeStartBuilder: (context, day, focusedDay) {
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
          rangeHighlightBuilder: (context, day, isWithinRange) {
            if (!isWithinRange) return null;

            final bandHeight = ResponsiveSize.scaleHeight(14);
            final bandColor = Colors.grey.shade300;

            if (rangeStart != null &&
                rangeEnd != null &&
                isSameDay(day, rangeStart!) &&
                isSameDay(day, rangeEnd!)) {
              return Center(
                child: Container(
                  width: ResponsiveSize.scaleWidth(28),
                  height: bandHeight,
                  decoration: BoxDecoration(
                    color: bandColor,
                  ),
                ),
              );
            }

            if (rangeStart != null && isSameDay(day, rangeStart!)) {
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

            if (rangeEnd != null && isSameDay(day, rangeEnd!)) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: ResponsiveSize.scaleWidth(20),
                  height: bandHeight,
                  decoration: BoxDecoration(
                    color: bandColor,
                  ),
                ),
              );
            }

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
        calendarFormat: calendarFormat,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: onDaySelected,
        rangeStartDay: rangeStart,
        onRangeSelected: onRangeSelected,
        rangeSelectionMode: RangeSelectionMode.toggledOn,
        rangeEndDay: rangeEnd,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF606060),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Theme.of(context).primaryColor.withOpacity(1),
            shape: BoxShape.circle,
          ),
          rangeStartDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
          ),
          rangeEndDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
          ),
          withinRangeDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
          ),
          rangeHighlightColor: Colors.grey.shade300,
        ),
        onPageChanged: onPageChanged,
      ),
    );
  }
}
