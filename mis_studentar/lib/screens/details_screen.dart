import 'package:flutter/material.dart';
import '../widgets/comments_section.dart';
import '../widgets/description.dart';
import 'package:mis_studentar/service/data_service.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final String description;
  final String entityType; // Add this parameter
  final String entityName; // Add this parameter

  const DetailsScreen({
    required this.title,
    required this.description,
    required this.entityType, // Add this parameter
    required this.entityName, // Add this parameter
  });

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final List<Map<String, String>> comments = [];
  final TextEditingController commentController = TextEditingController();
  bool _isLoading = true;
  final DataService _dataService = DataService(baseUrl: 'http://10.0.2.2:8000');

  @override
  void initState() {
    super.initState();
    _fetchComments(); // Fetch comments when the screen loads
  }

  Future<void> _fetchComments() async {
    try {
      // Replace with your API call to fetch comments
      final response = await _dataService.getComments(
        widget.entityType,
        widget.entityName,
      );

      setState(() {
        comments.addAll(response); // Add fetched comments to the list
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch comments: $e')),
      );
    }
  }

  Future<void> _addComment(String content) async {
    try {
      // Call the API to add the comment
      await _dataService.addComment(
        widget.entityType,
        widget.entityName,
        content,
      );

      // Update the local state
      setState(() {
        comments.add({
          "timestamp": DateTime.now().toString(),
          "content": content,
        });
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : CommentsSection(
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