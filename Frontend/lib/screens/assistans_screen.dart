import 'package:flutter/material.dart';
import 'details_screen.dart';

class AssistantsScreen extends StatelessWidget {
  final List<Map<String, String>> assistants = [
    {
      "name": "John Doe",
      "field": "Programming",
      "experience": "3 years",
      "id": "A01",
    },
    {
      "name": "Jane Smith",
      "field": "Mathematics",
      "experience": "5 years",
      "id": "A02",
    },
    {
      "name": "Emily Johnson",
      "field": "Physics",
      "experience": "2 years",
      "id": "A03",
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  title: assistant["name"]!,
                  subtitle: "Field: ${assistant["field"]}\nExperience: ${assistant["experience"]}",
                  trailing: assistant["id"]!,
                  details: assistant,
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
              title: details["name"]!, description: 'asdaDSAD',

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
