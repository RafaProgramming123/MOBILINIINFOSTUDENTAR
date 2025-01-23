import 'package:flutter/material.dart';
import '../widgets/comments_section.dart';
import '../widgets/description.dart';


class DetailsScreen extends StatefulWidget {
  final String title;
  final String description;

  const DetailsScreen({
    required this.title,
    required this.description,
  });

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final List<Map<String, String>> comments = [
    {
      "author": "Andrej Rafajlovski",
      "id": "211261",
      "timestamp": "20.12.2024 14:30",
      "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fringilla.",
    },
    {
      "author": "Andrej Rafajlovski",
      "id": "211261",
      "timestamp": "20.12.2024 14:30",
      "content": "Another example comment to show how it looks.",
    },
  ];

  final TextEditingController commentController = TextEditingController();

  void _addComment(String content) {
    setState(() {
      comments.add({
        "author": "Andrej Rafajlovski",
        "id": "211261",
        "timestamp": DateTime.now().toString(),
        "content": content,
      });
    });
    Navigator.pop(context);
  }

  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Add Comment',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          content: TextField(
            controller: commentController,
            maxLines: 4,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your comment here...',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  _addComment(commentController.text);
                  commentController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DescriptionSection(description: widget.description),
            SizedBox(height: 16),
            Expanded(
              child: CommentsSection(
                comments: comments,
                onAddComment: _showAddCommentDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
