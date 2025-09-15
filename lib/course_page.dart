import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makeit/course_detail_page.dart';
import 'package:makeit/message_page.dart';
import 'package:makeit/profile_page.dart';
import 'package:makeit/search.dart';
import 'package:makeit/student_homepage.dart';
import 'package:makeit/widgets/custom_nav_bar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  int _selectedIndex = 1;
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoursePage()),
        );
        break;
      // Already on CoursePage
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => searchPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MessagePage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()), // Replace with your account page
        );
    }
  }

  Future<void> loadCourses() async {
    try {
      final response = await rootBundle.loadString('assets/courses.json');
      final data = json.decode(response);
      setState(() => categories = data['categories']);
    } catch (e) {
      print("Error loading JSON: $e");
      // Handle error (e.g., show message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        backgroundColor: Color(0xFF47E6FB),
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        category['title'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: category['courses'].length,
                        itemBuilder: (context, i) {
                          final course = category['courses'][i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseDetailPage(
                                    courseTitle: course['title'] ?? 'No Title',
                                    duration: course['duration'] ?? '0h',
                                    lessonsCount: course['lessons'] ?? 0,
                                    description: course['description'] ??
                                        'No description available.',
                                    modules: course['modules'] != null
                                        ? List<Map<String, String>>.from(
                                            course['modules'].map((module) => {
                                                  'title': module['title'] ??
                                                      'Untitled Module',
                                                  'duration':
                                                      module['duration'] ?? '0',
                                                  'locked': module['locked'] ??
                                                      'false',
                                                }))
                                        : [],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15)),
                                    child: Image.asset(
                                      course['image'],
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      course['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                        '${course['duration']} - ${course['lessons']} lessons'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
