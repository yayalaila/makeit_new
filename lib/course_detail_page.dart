import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makeit/services/firestore_service.dart';
import 'package:makeit/models/course_model.dart';
import 'package:makeit/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  const CourseDetailPage({required this.courseId, super.key});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        backgroundColor: Color(0xFF47E6FB),
      ),
      body: StreamBuilder<Course?>(
        stream: _firestore.getCourseStream(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final course = snapshot.data;
          if (course == null) return Center(child: Text('Course not found'));

          final uid = _auth.currentUser?.uid;
          final isEnrolled = uid != null && course.enrolledUsers.contains(uid);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(course.imageUrl!,
                        height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                SizedBox(height: 12),
                Text(course.title,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('By ${course.mentorName}',
                        style: TextStyle(color: Colors.blue)),
                    Spacer(),
                    Text('${course.enrolledCount} enrolled',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 12),
                Text(course.description, style: TextStyle(fontSize: 16)),
                if (course.tags.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Wrap(
                      spacing: 8,
                      children: course.tags
                          .map((t) => Chip(label: Text(t)))
                          .toList()),
                ],
                SizedBox(height: 20),
                if (course.lessons.isNotEmpty) ...[
                  Text('Lessons',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...course.lessons.map((lesson) => Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lesson.title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              if (lesson.notes != null &&
                                  lesson.notes!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(lesson.notes!),
                              ],
                              if (lesson.youtubeLink != null &&
                                  lesson.youtubeLink!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(lesson.youtubeLink!,
                                            style:
                                                TextStyle(color: Colors.blue))),
                                    TextButton(
                                      onPressed: () async {
                                        final link = lesson.youtubeLink ?? '';
                                        if (link.isEmpty) return;
                                        final uri = Uri.tryParse(link);
                                        if (uri == null) return;
                                        try {
                                          await launchUrl(uri,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Could not open link')));
                                        }
                                      },
                                      child: Text('Open'),
                                    )
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ))
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final currentUser = _auth.currentUser;
                      if (currentUser == null) {
                        // prompt login
                        final shouldLogin = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Sign in required'),
                            content: Text(
                                'You need to sign in to enroll. Go to login?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Login')),
                            ],
                          ),
                        );
                        if (shouldLogin == true) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => LoginScreen()));
                        }
                        return;
                      }

                      try {
                        if (!isEnrolled) {
                          await _firestore.enrollInCourse(course.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Enrolled successfully')));
                        } else {
                          await _firestore.unenrollFromCourse(course.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Unenrolled successfully')));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEnrolled ? Colors.grey : Color(0xFF47E6FB),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isEnrolled ? 'Unenroll' : 'Enroll',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
