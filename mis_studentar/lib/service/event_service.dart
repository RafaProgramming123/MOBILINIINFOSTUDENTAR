import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mis_studentar/domain/event.dart'; // Import the Event model

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new event
  Future<String> createEvent(Event event) async {
  try {
    // Get the current user's reference
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'No user logged in';
    }

    // Get a reference to the user document in Firestore
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Update the event with the user's reference
    event.userRef = userRef;

    // Save the event to Firestore
    await FirebaseFirestore.instance.collection('events').add(event.toJson());

    return 'Event created successfully';
  } catch (e) {
    return 'Error: $e';
  }
}

  // Retrieve events for the user on a specific date (ignoring time)
  // Future<List<Event>> getUserEventsByDate(DateTime date) async {
  //   try {
  //     User? currentUser = _auth.currentUser;

  //     if (currentUser == null) {
  //       throw Exception('No user is currently authenticated');
  //     }

  //     // Get the start and end of the day to filter events for the specific date
  //     DateTime startOfDay = DateTime(date.year, date.month, date.day);
  //     DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  //     // Query Firestore for events that match the date (ignoring time)
  //     QuerySnapshot querySnapshot = await _firestore
  //         .collection('events')
  //         .where('createdBy', isEqualTo: currentUser.uid)
  //         .where('datetime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
  //         .where('datetime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
  //         .get();

  //     // Convert the query results into a list of Event objects
  //     List<Event> events = querySnapshot.docs
  //         .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
  //         .toList();

  //     return events;
  //   } catch (e) {
  //     throw Exception('Error retrieving events: ${e.toString()}');
  //   }
  // }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      // Get the current user's ID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Query events for the selected date and user
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('userRef', isEqualTo: _firestore.collection('users').doc(user.uid))
          .where('datetime', isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day))
          .where('datetime', isLessThan: DateTime(date.year, date.month, date.day + 1))
          .get();

      // Convert documents to a list of Event objects
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Fetched event data: $data'); // Log the fetched data
        return Event.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }
}
