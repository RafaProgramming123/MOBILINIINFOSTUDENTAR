import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FullscreenMap extends StatefulWidget {
  final LatLng initialLocation;

  FullscreenMap({required this.initialLocation});

  @override
  _FullscreenMapState createState() => _FullscreenMapState();
}

class _FullscreenMapState extends State<FullscreenMap> {
  LatLng _selectedLocation = LatLng(42.00452183173436, 21.40652447690133); // Default location
  String _selectedInfo = ''; // Store the info of the selected location
  final MapController _mapController = MapController();
  double _zoomLevel = 18.0; // Initial zoom level

  // Different sets of predefined points
  final Map<int, List<Map<String, dynamic>>> _predefinedPointSets = {
    -1: [
      {
        'name': 'Просторија 2',
        'location': LatLng(42.00456510275695, 21.41003616067788),
        'info': 'Просторија 2 - ТМФ (лабораториска)',
      },
      {
        'name': 'Просторија 3',
        'location': LatLng(42.00457805807921, 21.40993960115213),
        'info': 'Просторија 3 - ТМФ (лабораториска)',
      },
    ],
    0: [
      {
        'name': 'Барака 1',
        'location': LatLng(42.00452183173436, 21.40652447690133),
        'info': 'Барака 1 - ФИНКИ',
      },
      {
        'name': 'Барака 2.1',
        'location': LatLng(42.00465138492951, 21.406611648700096),
        'info': 'Барака 2.1 - ФИНКИ',
      },
      {
        'name': 'Барака 2.2',
        'location': LatLng(42.0046723127281, 21.406473514934085),
        'info': 'Барака 2.2 - ФИНКИ',
      },
      {
        'name': 'Барака 3.1',
        'location': LatLng(42.00479887593677, 21.406661269567277),
        'info': 'Барака 3.1 - ФИНКИ',
      },
      {
        'name': 'Барака 3.2',
        'location': LatLng(42.00482279336485, 21.40651106586055),
        'info': 'Барака 3.2 - ФИНКИ',
      },
      {
        'name': 'Амфитеатар',
        'location': LatLng(42.00518055715937, 21.407860216999502),
        'info': 'Амфитеатар - МФ'
      },
      {
        'name': 'Амфитеатар',
        'location': LatLng(42.00433148771571, 21.409048435598123),
        'info': 'Амфитеатар голем - ФИНКИ '
      },
    ],
    1: [
      {
        'name': 'Просторија 138',
        'location': LatLng(42.004531797376394, 21.41028627505733),
        'info': 'Просторија 138 ТМФ',
      },
      {
        'name': 'Просторија 115',
        'location': LatLng(42.00488956280274, 21.410158870126992),
        'info': 'Просторија 115 ТМФ',
      },
    ],
    2: [
      {
        'name': 'Просторија 215',
        'location': LatLng(42.0051177742418, 21.408137825629645),
        'info': 'Просторија 215 - МФ',
      },
    ],
  };

  List<Map<String, dynamic>> _predefinedPoints = []; // Current set of points

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _predefinedPoints = _predefinedPointSets[0]!; // Load default points (set 0)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_selectedLocation, _zoomLevel);
    });
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