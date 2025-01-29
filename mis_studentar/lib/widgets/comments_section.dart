import 'package:flutter/material.dart';

class CommentsSection extends StatelessWidget {
  final List<Map<String, String>> comments;
  final VoidCallback onAddComment;

  const CommentsSection({
    required this.comments,
    required this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        comment['content']!,
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        comment['timestamp']!,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            backgroundColor: Colors.cyanAccent,
            onPressed: onAddComment,
            child: Icon(Icons.add_comment, color: Colors.black),
          ),
        ),
      ],
    );
  }
}