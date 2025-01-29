import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'package:provider/provider.dart';
import 'package:mis_studentar/providers/DataProvider.dart';

class AssistantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch the DataStore instance from Provider
    final dataStore = Provider.of<DataStore>(context);

    // Fetch data if not already loaded
    if (dataStore.professorAssistants.isEmpty) {
      dataStore.fetchData(); // Ensure data is loaded
    }

    final assistants = dataStore.assistants;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Assistants',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: assistants.length,
              itemBuilder: (context, index) {
                final assistant = assistants[index];
                return _buildCard(
                  context,
                  title: assistant,
                  subtitle: assistant,
                  trailing: assistant,
                  details: {"name": assistant},
                  entityType: "assistant", // Pass the entity type
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
              title: details["name"]!,
              description: 'Detailed information goes here.',
              entityType: entityType, // Pass the entity type
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