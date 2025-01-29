import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DataService {
  final String baseUrl;

  DataService({required this.baseUrl});

  // Fetch courses from the API
  Future<List<String>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['courses']);
    } else {
      throw Exception('Failed to load courses');
    }
  }

  // Fetch professors from the API
  Future<List<String>> getProfessors() async {
    final response = await http.get(Uri.parse('$baseUrl/professors'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['professors']);
    } else {
      throw Exception('Failed to load professors');
    }
  }

  // Fetch assistants from the API
  Future<List<String>> getAssistants() async {
    final response = await http.get(Uri.parse('$baseUrl/assistants'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['assistants']);
    } else {
      throw Exception('Failed to load assistants');
    }
  }

  // Combine professors and assistants into one list
  Future<List<String>> getProfessorAssistants() async {
    final professors = await getProfessors();
    final assistants = await getAssistants();
    return [...professors, ...assistants]; // Concatenate the two lists
  }

  Future<List<Map<String, String>>> getComments(String entityType, String entityName) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/$entityType/$entityName'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Received data: $data");

      // Ensure that comments are being handled as expected
      if (data is List) {
        List<Map<String, String>> commentsList = List<Map<String, String>>.from(
          data.map((comment) {
            print("Processing comment: $comment"); // Debugging line
            // Make sure the comment is structured as expected
            return {
              "timestamp": comment["time"].toString(),  // Using the time as timestamp
              "content": comment["comment"].toString(), // The actual comment text
            };
          })
        );
        
        return commentsList;
      } else {
        throw Exception('Invalid data structure: Expected a list of comments');
      }
    } else {
      throw Exception('Failed to load comments');
    }
  }


  Future<void> addComment(String entityType, String entityName, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/$entityType/$entityName'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"comment": comment, "time": DateTime.now().toIso8601String()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add comment');
    }
  }
}