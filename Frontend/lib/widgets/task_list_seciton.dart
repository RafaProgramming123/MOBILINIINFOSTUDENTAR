import 'package:flutter/material.dart';

class TaskListSection extends StatelessWidget {
  final Map<DateTime, List<Map<String, String>>> tasks;
  final DateTime? selectedDay;

  const TaskListSection({
    required this.tasks,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return tasks[selectedDay]?.isEmpty ?? true
        ? Center(
      child: Text(
        'No tasks for this day.',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    )
        : ListView.builder(
      itemCount: tasks[selectedDay]!.length,
      itemBuilder: (context, index) {
        final task = tasks[selectedDay]![index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              task['course']!,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Type: ${task['type']}\nProfessor/Assistant: ${task['professorAssistant']}\nTime: ${task['time']}',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}
