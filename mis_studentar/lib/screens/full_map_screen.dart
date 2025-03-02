import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mis_studentar/service/data_service.dart'; // Import the DataService

class FullscreenMap extends StatefulWidget {
  final LatLng initialLocation;
  final DataService dataService; // Add DataService as a parameter

  FullscreenMap({required this.initialLocation, required this.dataService});

  @override
  _FullscreenMapState createState() => _FullscreenMapState();
}

class _FullscreenMapState extends State<FullscreenMap> {
  LatLng _selectedLocation = LatLng(42.00452183173436, 21.40652447690133); // Default location
  String _selectedInfo = ''; // Store the info of the selected location
  final MapController _mapController = MapController();
  double _zoomLevel = 18.0; // Initial zoom level

  Map<int, List<Map<String, dynamic>>> _predefinedPointSets = {}; // Predefined points fetched from the backend
  List<Map<String, dynamic>> _predefinedPoints = []; // Current set of points

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _fetchPredefinedPoints(); // Fetch predefined points from the backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_selectedLocation, _zoomLevel);
    });
  }

  // Fetch predefined points from the backend
  void _fetchPredefinedPoints() async {
    try {
      final points = await widget.dataService.getPredefinedPoints();
      setState(() {
        _predefinedPointSets = points;
        _predefinedPoints = _predefinedPointSets[0] ?? []; // Load default points (set 0)
      });
    } catch (e) {
      print('Failed to fetch predefined points: $e');
    }
  }

  void _getUserLocation() async {
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
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_selectedLocation, _zoomLevel);
    });
  }

  void _showPointInfo(Map<String, dynamic> point) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(point['name']),
          content: Text(point['info']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel += 1.0; // Increase zoom level
      _mapController.move(_selectedLocation, _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel -= 1.0; // Decrease zoom level
      _mapController.move(_selectedLocation, _zoomLevel);
    });
  }

  void _loadPredefinedPoints(int setNumber) {
    setState(() {
      _predefinedPoints = _predefinedPointSets[setNumber] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _selectedLocation,
                    zoom: _zoomLevel,
                    onTap: (tapPosition, point) {
                      // Check if the tapped point is near any predefined point
                      for (var predefinedPoint in _predefinedPoints) {
                        final distance = Distance().as(
                          LengthUnit.Meter,
                          point,
                          predefinedPoint['location'],
                        );

                        // If the distance is less than 50 meters, consider it a hit
                        if (distance < 3) {
                          setState(() {
                            _selectedLocation = predefinedPoint['location'];
                            _selectedInfo = predefinedPoint['info']; // Store the info
                          });
                          _showPointInfo(predefinedPoint);
                          break;
                        }
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        // Marker for the selected location
                        Marker(
                          point: _selectedLocation,
                          width: 80.0,
                          height: 80.0,
                          builder: (ctx) => Icon(
                            Icons.location_on,
                            size: 40.0,
                            color: Colors.red,
                          ),
                        ),
                        // Markers for predefined points
                        ..._predefinedPoints.map((point) {
                          return Marker(
                            point: point['location'],
                            width: 40.0,
                            height: 40.0,
                            builder: (ctx) => Icon(
                              Icons.location_pin,
                              size: 30.0,
                              color: Colors.blue,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Return both the location and the info
                    Navigator.pop(context, {
                      'location': _selectedLocation,
                      'info': _selectedInfo,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  ),
                  child: Text(
                    'Confirm Location',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          // Vertical buttons for predefined point sets
          Positioned(
            top: 16.0, // Adjust the top position as needed
            right: 16.0, // Adjust the right position as needed
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () => _loadPredefinedPoints(-1),
                  mini: true,
                  backgroundColor: Colors.cyanAccent,
                  child: Text('-1', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _loadPredefinedPoints(0),
                  mini: true,
                  backgroundColor: Colors.cyanAccent,
                  child: Text('0', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _loadPredefinedPoints(1),
                  mini: true,
                  backgroundColor: Colors.cyanAccent,
                  child: Text('1', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _loadPredefinedPoints(2),
                  mini: true,
                  backgroundColor: Colors.cyanAccent,
                  child: Text('2', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
          // Zoom and location buttons
          Positioned(
            bottom: 16.0, // Adjust the bottom position as needed
            right: 16.0, // Adjust the right position as needed
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  mini: true,
                  backgroundColor: Colors.cyanAccent,
                  child: Icon(Icons.add, color: Colors.black),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  mini: true,
                  backgroundColor: Colors.cyanAccent,
                  child: Icon(Icons.remove, color: Colors.black),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _getUserLocation,
                  backgroundColor: Colors.cyanAccent,
                  child: Icon(Icons.my_location, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}