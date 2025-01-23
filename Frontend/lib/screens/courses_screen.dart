import 'package:flutter/material.dart';
import 'details_screen.dart';

class CoursesScreen extends StatelessWidget {
  final List<Map<String, String>> courses = [
    {
      "title": "Structured Programming",
      "semester": "1",
      "type": "Programming",
      "code": "F11S223",
    },
    {
      "title": "Algorithms and Data Structures",
      "semester": "2",
      "type": "Programming",
      "code": "F11S224",
    },
    {
      "title": "Discrete Mathematics",
      "semester": "1",
      "type": "Mathematics",
      "code": "M11S123",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Courses',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _buildCard(
                  context,
                  title: course["title"]!,
                  subtitle: "Semester: ${course["semester"]}\nType: ${course["type"]}",
                  trailing: course["code"]!,
                  details: course,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required String subtitle, required String trailing, required Map<String, String> details}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              title: details["title"]!, description: 'HAHAHAHAHAHAH',


            ),
          ),
        );
      },
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            trailing,
            style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
