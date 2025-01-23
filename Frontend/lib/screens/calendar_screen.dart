import 'package:flutter/material.dart';
import '../widgets/calendar_section.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/task_list_seciton.dart';
import 'add_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, String>>> _tasks = {};

  void _addTask(String type, String course, String professorAssistant, String time) {
    setState(() {
      if (_tasks[_selectedDay!] == null) {
        _tasks[_selectedDay!] = [];
      }
      _tasks[_selectedDay!]!.add({
        "type": type,
        "course": course,
        "professorAssistant": professorAssistant,
        "time": time,
      });
    });
  }

  void _navigateToAddTaskScreen() async {
    final task = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(),
      ),
    );

    if (task != null) {
      _addTask(
        task['type'],
        task['course'],
        task['professorAssistant'],
        task['time'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Welcome!',
          style: TextStyle(color: Colors.cyanAccent),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.cyanAccent),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.cyanAccent),
            onPressed: () {

            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarSection(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          Expanded(
            child: TaskListSection(
              tasks: _tasks,
              selectedDay: _selectedDay,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _navigateToAddTaskScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  minimumSize: Size(120, 50),
                ),
                child: Text(
                  'Add Task',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
