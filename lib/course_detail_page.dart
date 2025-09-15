import 'package:flutter/material.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseTitle;
  final String duration;
  final int lessonsCount;
  final String description;
  final List<Map<String, String>> modules;

  const CourseDetailPage({
    super.key,
    required this.courseTitle,
    required this.duration,
    required this.lessonsCount,
    required this.description,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF47E6FB),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Placeholder for the illustration
                  Image.asset('assets/programing.jpeg',
                      height: 120), // replace with your asset
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('$duration · $lessonsCount Lessons'),
                  SizedBox(height: 10),
                  Text('About this course',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(description),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      final module = modules[index];
                      return ListTile(
                        leading: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Text(module['title'] ?? ''),
                        subtitle: Text('${module['duration'] ?? '0'} mins'),
                        trailing: Icon(
                          module['locked'] == 'true'
                              ? Icons.lock
                              : Icons.play_circle_fill,
                          color: Color(0xFF47E6FB),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Rate'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
