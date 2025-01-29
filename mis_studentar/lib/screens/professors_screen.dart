import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'details_screen.dart';
import 'package:mis_studentar/providers/DataProvider.dart';

class ProfessorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch the DataStore instance from Provider
    final dataStore = Provider.of<DataStore>(context);

    // Fetch data if not already loaded
    if (dataStore.professorAssistants.isEmpty) {
      dataStore.fetchData(); // Ensure data is loaded
    }

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
            child: Consumer<DataStore>(
              builder: (context, dataStore, child) {
                final professors = dataStore.professors;

                if (professors.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: professors.length,
                  itemBuilder: (context, index) {
                    final professor = professors[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              title: professor, // Pass the professor's name
                              description: 'Detailed information goes here.',
                              entityType: "professor", // Pass the entity type
                              entityName: professor, // Pass the entity name
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            professor,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Additional details can go here.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}