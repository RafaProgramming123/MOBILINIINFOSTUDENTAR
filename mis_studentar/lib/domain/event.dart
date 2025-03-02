import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String type;
  final String course;
  final DateTime datetime;
  final String professor;
  final GeoPoint location;
  final String location_name;
  DocumentReference userRef; // Store a reference to the user document

  Event({
    required this.id,
    required this.type,
    required this.course,
    required this.datetime,
    required this.location,
    required this.professor,
    required this.userRef,
    required this.location_name,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'course': course,
      'datetime': datetime,
      'location': location,
      'location_name': location_name,
      'professor': professor,
      'userRef': userRef,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'] ?? '', // Provide a default value if null
        type: json['type'] ?? 'Unknown', // Provide a default value if null
        course: json['course'] ?? 'Unknown', // Provide a default value if null
        datetime: (json['datetime'] as Timestamp).toDate(), // Ensure datetime is not null
        location: json['location'] ?? GeoPoint(0, 0), // Provide a default value if null
        location_name: json['location_name'] ?? "",
        professor: json['professor'] ?? 'Unknown', // Provide a default value if null
        userRef: json['userRef'], // Ensure userRef is not null
      );
    } catch (e) {
      throw Exception('Failed to parse Event: $e');
    }
  }
}