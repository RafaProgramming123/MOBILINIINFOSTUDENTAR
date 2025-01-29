import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'package:mis_studentar/providers/DataProvider.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch the DataStore instance from Provider
    final dataStore = Provider.of<DataStore>(context);

    // Fetch data if not already loaded
    if (dataStore.courses.isEmpty) {
      dataStore.fetchData(); // Ensure data is loaded
    }

    final courses = dataStore.courses;

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
                  title: course,
                  subtitle: course,
                  trailing: course,
                  details: {"title": course},
                  entityType: "course", // Pass the entity type
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

  Widget _buildCard(BuildContext context, {required String title, required String subtitle, required String trailing, required Map<String, String> details, required String entityType}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              title: details["title"]!,
              description: 'Detailed information goes here.',
              entityType: entityType,
              entityName: title,
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
        ),
      ),
    );
  }
}