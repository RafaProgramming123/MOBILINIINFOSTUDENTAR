import 'package:flutter/material.dart';
import '../widgets/calendar_section.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/task_list_section.dart';
import 'add_task_screen.dart';
import '../service/event_service.dart'; // Import the EventService
import '../domain/event.dart'; // Import the Event model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mis_studentar/screens/profile_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<Event>> _tasks = {}; // Use List<Event> instead of List<Map<String, String>>
  final EventService _eventService = EventService(); // Create an instance of EventService
  String? _profilePictureUrl; // Add this variable

  void _addTask(String type, String course, String professorAssistant, String time) {
    setState(() {
      if (_tasks[_selectedDay!] == null) {
        _tasks[_selectedDay!] = [];
      }
      _tasks[_selectedDay!]!.add(Event(
        id: '', // Firestore will generate the ID
        type: type,
        course: course,
        datetime: DateTime.now(), // Replace with the actual datetime
        location: GeoPoint(0, 0), // Replace with the actual location
        professor: professorAssistant,
        userRef: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid),
      ));
    });
  }

  void _navigateToAddTaskScreen() async {
    final task = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(selectedDate: _selectedDay ?? DateTime.now()), // Pass the selected date
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

  // Fetch events for the selected date
  Future<void> _fetchEventsForSelectedDate() async {
    if (_selectedDay == null) return;

    try {
      final events = await _eventService.getEventsForDate(_selectedDay!);
      setState(() {
        _tasks[_selectedDay!] = events;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch events: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEventsForSelectedDate(); // Fetch events when the screen is first loaded
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: _profilePictureUrl != null
                  ? NetworkImage(_profilePictureUrl!)
                  : null,
              child: _profilePictureUrl == null
                  ? Icon(Icons.person, size: 20, color: Colors.cyanAccent)
                  : null,
            ),
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
              _fetchEventsForSelectedDate(); // Fetch events when a new date is selected
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