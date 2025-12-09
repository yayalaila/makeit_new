import 'package:flutter/material.dart';

class UploadCoursePage extends StatelessWidget {
  final String category;

  const UploadCoursePage({super.key, required this.category});

  Null get import => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload $category Course'),
        backgroundColor: Color(0xFF00CFFF),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Course Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Course Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Save course logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('Upload Course'),
            )
          ],
        ),
      ),
    );
  }
}
