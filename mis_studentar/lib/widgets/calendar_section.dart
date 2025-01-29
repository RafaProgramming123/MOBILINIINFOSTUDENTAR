import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarSection({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Schedule',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TableCalendar(
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.cyanAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.cyan,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: Colors.white),
            weekendTextStyle: TextStyle(color: Colors.white70),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(color: Colors.cyanAccent, fontSize: 18),
            formatButtonTextStyle: TextStyle(color: Colors.black),
            formatButtonDecoration: BoxDecoration(
              color: Colors.cyanAccent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.cyanAccent),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.cyanAccent),
          ),
        ),
      ],
    );
  }
}