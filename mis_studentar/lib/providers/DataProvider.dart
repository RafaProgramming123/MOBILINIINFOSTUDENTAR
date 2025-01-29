import 'package:flutter/material.dart';
import 'package:mis_studentar/service/data_service.dart';

class DataStore extends ChangeNotifier {
  final DataService _dataService = DataService(baseUrl: 'http://10.0.2.2:8000');
  List<String> _courses = [];
  List<String> _professorAssistants = [];
  List<String> _professors = [];
  List<String> _assistants = [];

  List<String> get courses => _courses;
  List<String> get professorAssistants => _professorAssistants;
  List<String> get professors => _professors;
  List<String> get assistants => _assistants;

  Future<void> fetchData() async {
    try {
      final courses = await _dataService.getCourses();
      final professorAssistants = await _dataService.getProfessorAssistants();
      final professors = await _dataService.getProfessors();
      final assistants = await _dataService.getAssistants();

      _courses = courses;
      _professorAssistants = professorAssistants;
      _professors = professors;
      _assistants = assistants;

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}
