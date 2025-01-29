import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For latitude and longitude
import 'package:cloud_firestore/cloud_firestore.dart'; // For GeoPoint
import 'package:mis_studentar/domain/event.dart';
import 'package:mis_studentar/service/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current user's UID
import 'package:geolocator/geolocator.dart'; // For location services

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = '';
  String _course = '';
  String _professor = '';
  DateTime _datetime = DateTime.now();
  String _eventId = ''; // Event ID, can be a generated value or user input

  // Default location for demonstration
  LatLng _location = LatLng(37.7749, -122.4194); // San Francisco coordinates
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("TEST");
    if (!serviceEnabled) {
      // Location services are not enabled, show a message or return
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message or return
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, show a message or return
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Event Type'),
                onSaved: (value) => _type = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event type';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Course'),
                onSaved: (value) => _course = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Professor'),
                onSaved: (value) => _professor = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter professor\'s name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Event ID'),
                onSaved: (value) => _eventId = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unique event ID';
                  }
                  return null;
                },
              ),
              // Date and time picker
              ListTile(
                title: Text("Event Date and Time"),
                subtitle: Text('${_datetime.toLocal()}'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _datetime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _datetime) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_datetime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _datetime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              // OpenStreetMap for location input
              Container(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: _location,
                    zoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _location = point; // Update location when the map is tapped
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _location,
                          width: 80.0,
                          height: 80.0,
                          builder: (ctx) => Icon(
                            Icons.location_on,
                            size: 40.0,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Save form data
      _formKey.currentState!.save();

      // Get the current user's reference
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user logged in')));
        return;
      }

      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Create event with the user reference
      Event newEvent = Event(
        id: _eventId,
        type: _type,
        course: _course,
        datetime: _datetime,
        professor: _professor,
        location: GeoPoint(_location.latitude, _location.longitude),
        userRef: userRef, // Set the user reference here
      );

      // Call the event service to create the event
      String result = await _eventService.createEvent(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

      // Optionally, navigate back after creating the event
      if (result == 'Event created successfully') {
        Navigator.pop(context);
      }
    }
  }
}