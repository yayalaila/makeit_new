import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makeit/models/course_model.dart';
import 'package:makeit/services/firestore_service.dart';

class UploadCoursePage extends StatefulWidget {
  const UploadCoursePage({super.key});

  @override
  _UploadCoursePageState createState() => _UploadCoursePageState();
}

class _UploadCoursePageState extends State<UploadCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final tagsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _uploadCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final newCourse = Course(
        id: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        mentorId: user.uid,
        mentorName: user.displayName ?? 'Mentor',
        price: double.parse(priceController.text.trim()),
        createdAt: DateTime.now(),
        tags: tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .toList(),
      );

      await _firestoreService.uploadCourse(newCourse);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course uploaded successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Course'),
        backgroundColor: Color(0xFF47E6FB),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Course Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Price is required';
                  if (double.tryParse(value) == null) return 'Invalid price';
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF47E6FB),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Upload Course',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
