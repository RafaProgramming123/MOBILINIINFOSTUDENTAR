import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mis_studentar/service/event_service.dart'; // Import the EventService
import 'package:mis_studentar/domain/event.dart'; // Import the Event model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mis_studentar/providers/DataProvider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // For location services
import 'package:mis_studentar/screens/full_map_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final DateTime selectedDate; // Add this to pass the selected date from CalendarScreen

  AddTaskScreen({required this.selectedDate}); // Constructor to receive the selected date

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String? selectedType;
  String? selectedCourse;
  String? selectedProfessorAssistant;
  TimeOfDay? _selectedTime; // Store the selected time

  final List<String> typeOptions = ['Lecture', 'Exam', 'Assignment'];
  List<String> courseOptions = []; // Will be populated from the API
  List<String> professorAssistantOptions = []; // Will be populated from the API

  final EventService _eventService = EventService(); // Create an instance of EventService
  // final DataService _dataService = DataService(baseUrl: 'http://10.0.2.2:8000'); // Create an instance of DataService

  LatLng _location = LatLng(45.8125, 15.9778); // Default location (e.g., Zagreb)
    final MapController _mapController = MapController(); // Add MapController

  @override
  void initState() {
    super.initState();
    final dataStore = Provider.of<DataStore>(context, listen: false);
    setState(() {
      courseOptions = dataStore.courses;
      professorAssistantOptions = dataStore.professorAssistants;
    });
    _getUserLocation();
  }


  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
      _mapController.move(_location, 13.0); // Move map to user's location
    });
  }

  // Function to open the time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime; // Update the selected time
      });
    }
  }

  void _submitTask() async {
    if (selectedType != null &&
        selectedCourse != null &&
        selectedProfessorAssistant != null &&
        _selectedTime != null) {
      // Convert the selected time to a DateTime object
      DateTime eventDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _selectedTime!.hour, // Use the selected hour
        _selectedTime!.minute, // Use the selected minute
      );

      // Create an Event object with the selected location
      Event event = Event(
        id: '', // Firestore will generate the ID
        type: selectedType!,
        course: selectedCourse!,
        datetime: eventDateTime,
        location: GeoPoint(_location.latitude, _location.longitude), // Use the selected location
        professor: selectedProfessorAssistant!,
        userRef: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid), // Set the user reference
      );

      // Call the createEvent method from EventService
      String result = await _eventService.createEvent(event);

      if (result == 'Event created successfully') {
        // Return the task details to the CalendarScreen
        Navigator.pop(context, {
          'type': selectedType,
          'course': selectedCourse,
          'professorAssistant': selectedProfessorAssistant,
          'time': _selectedTime!.format(context), // Pass the selected time back
          'location': _location, // Pass the selected location back
        });
      } else {
        // Show an error message if event creation fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _openFullscreenMap() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenMap(
          initialLocation: LatLng(_location.latitude, _location.longitude), // Set an initial location
        ),
      ),
    );

    // Handle the returned location if it's not null
    if (selectedLocation != null) {
      setState(() {
        _location = selectedLocation;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected Location: (${selectedLocation.latitude}, ${selectedLocation.longitude})',
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Add Task',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Task Details',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            _buildDropdown(
              label: 'Type',
              value: selectedType,
              items: typeOptions,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            _buildDropdown(
              label: 'Course',
              value: selectedCourse,
              items: courseOptions,
              onChanged: (value) {
                setState(() {
                  selectedCourse = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            _buildDropdown(
              label: 'Professor/Assistant',
              value: selectedProfessorAssistant,
              items: professorAssistantOptions,
              onChanged: (value) {
                setState(() {
                  selectedProfessorAssistant = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Select Time',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () => _selectTime(context), // Open the time picker
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : 'Selected Time: ${_selectedTime!.format(context)}', // Display the selected time
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Select Location',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _openFullscreenMap, // Call fullscreen map
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Open Fullscreen Map',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.cyanAccent, fontSize: 16.0),
        ),
        SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.grey[900],
            style: TextStyle(color: Colors.white),
            icon: Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
            underline: SizedBox(),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}