import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Fetch user data (index and UID) from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data(); // Returns a Map<String, dynamic>
      } else {
        return null; // Document does not exist
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}