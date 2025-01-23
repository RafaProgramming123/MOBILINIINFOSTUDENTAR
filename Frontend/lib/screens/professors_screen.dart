import 'package:flutter/material.dart';
import 'details_screen.dart';

class ProfessorsScreen extends StatelessWidget {
  final List<Map<String, String>> professors = [
    {
      "name": "Prof. John Smith",
      "department": "Computer Science",
      "experience": "10 years",
    },
    {
      "name": "Prof. Emily Davis",
      "department": "Mathematics",
      "experience": "8 years",
    },
    {
      "name": "Prof. Alan Turing",
      "department": "Physics",
      "experience": "15 years",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Professors',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: professors.length,
              itemBuilder: (context, index) {
                final professor = professors[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          title: professor["name"]!, description: 'adaDS',

                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        professor["name"]!,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Department: ${professor["department"]}\nExperience: ${professor["experience"]}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
