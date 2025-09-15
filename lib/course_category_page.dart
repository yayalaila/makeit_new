import 'package:flutter/material.dart';
import 'package:makeit/course_upload_page.dart';

class CourseCategoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'title': 'Vocational', 'icon': Icons.handyman},
    {'title': 'Technical', 'icon': Icons.build},
    {'title': 'Adult Education', 'icon': Icons.school},
    {'title': 'Elementary Education', 'icon': Icons.menu_book},
  ];

  CourseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Course Category'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.orange.shade50,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Icon(category['icon'], color: Colors.orange),
              title: Text(
                category['title'],
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        UploadCoursePage(category: category['title']),
                  ),
                );

                // Navigate to course creation form for this category
              },
            ),
          );
        },
      ),
    );
  }
}
