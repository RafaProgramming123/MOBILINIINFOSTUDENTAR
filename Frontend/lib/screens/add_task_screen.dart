import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String? selectedType;
  String? selectedCourse;
  String? selectedProfessorAssistant;
  String? selectedTime;

  final List<String> typeOptions = ['Lecture', 'Exam', 'Assignment'];
  final List<String> courseOptions = ['Mathematics', 'Physics', 'Chemistry'];
  final List<String> professorAssistantOptions = ['Prof. Smith', 'Assist. Johnson'];
  final List<String> timeOptions = ['08:00 AM', '10:00 AM', '12:00 PM'];

  void _submitTask() {
    if (selectedType != null &&
        selectedCourse != null &&
        selectedProfessorAssistant != null &&
        selectedTime != null) {
      Navigator.pop(context, {
        'type': selectedType,
        'course': selectedCourse,
        'professorAssistant': selectedProfessorAssistant,
        'time': selectedTime,
      });
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
            _buildDropdown(
              label: 'Time',
              value: selectedTime,
              items: timeOptions,
              onChanged: (value) {
                setState(() {
                  selectedTime = value;
                });
              },
            ),
            Spacer(),
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
