import 'package:flutter/material.dart';
import 'package:makeit/models/course_model.dart';
import 'package:makeit/services/firestore_service.dart';

class BrowseCoursesPage extends StatefulWidget {
  const BrowseCoursesPage({super.key});

  @override
  _BrowseCoursesPageState createState() => _BrowseCoursesPageState();
}

class _BrowseCoursesPageState extends State<BrowseCoursesPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Courses'),
        backgroundColor: Color(0xFF47E6FB),
      ),
      body: StreamBuilder<List<Course>>(
        stream: _firestoreService.getCoursesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return Center(child: Text('No courses available'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseCard(course: course);
            },
          );
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF47E6FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${course.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              course.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By ${course.mentorName}',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                Text(
                  '${course.enrolledCount} enrolled',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (course.tags.isNotEmpty) ...[
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: course.tags
                    .map((tag) => Chip(
                          label: Text(tag, style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.grey[200],
                        ))
                    .toList(),
              ),
            ],
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF47E6FB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
