import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makeit/models/course_model.dart';
import 'package:makeit/services/firestore_service.dart';

class UploadCoursePage extends StatefulWidget {
  final Course? course; // optional existing course for editing

  const UploadCoursePage({super.key, this.course});

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
  // lesson controllers stored as maps for dynamic forms
  final List<Map<String, TextEditingController>> _lessonControllers = [];

  bool _isLoading = false;

  bool get isEditing => widget.course != null;

  Future<void> _uploadCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final newCourse = Course(
        id: isEditing ? widget.course!.id : '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        mentorId: user.uid,
        mentorName: user.displayName ?? 'Mentor',
        price: double.parse(priceController.text.trim()),
        lessons: _lessonControllers
            .map((m) => Lesson(
                title: m['title']!.text.trim(),
                notes: m['notes']!.text.trim().isEmpty
                    ? null
                    : m['notes']!.text.trim(),
                youtubeLink: m['youtube']!.text.trim().isEmpty
                    ? null
                    : m['youtube']!.text.trim()))
            .toList(),
        createdAt: DateTime.now(),
        tags: tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .toList(),
      );

      if (isEditing) {
        // preserve original createdAt if available
        final updated = Course(
          id: newCourse.id,
          title: newCourse.title,
          description: newCourse.description,
          mentorId: newCourse.mentorId,
          mentorName: newCourse.mentorName,
          imageUrl: newCourse.imageUrl,
          price: newCourse.price,
          enrolledCount: widget.course?.enrolledCount ?? 0,
          enrolledUsers: widget.course?.enrolledUsers ?? [],
          createdAt: widget.course!.createdAt,
          tags: newCourse.tags,
          lessons: newCourse.lessons,
        );
        await _firestoreService.updateCourse(updated);
      } else {
        await _firestoreService.uploadCourse(newCourse);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course uploaded successfully!')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
    for (final map in _lessonControllers) {
      for (var c in map.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // If editing, prefill controllers
    final c = widget.course;
    if (c != null) {
      titleController.text = c.title;
      descriptionController.text = c.description;
      priceController.text = c.price.toString();
      tagsController.text = c.tags.join(',');
      // load lessons
      for (final lesson in c.lessons) {
        _lessonControllers.add({
          'title': TextEditingController(text: lesson.title),
          'notes': TextEditingController(text: lesson.notes ?? ''),
          'youtube': TextEditingController(text: lesson.youtubeLink ?? ''),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Upload Course'),
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
              // Lessons section
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Lessons',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              ..._lessonControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final ctrls = entry.value;
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: ctrls['title'],
                          decoration: InputDecoration(
                              labelText: 'Lesson Title',
                              border: OutlineInputBorder()),
                          validator: (v) =>
                              v!.isEmpty ? 'Lesson title required' : null,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: ctrls['notes'],
                          decoration: InputDecoration(
                              labelText: 'Notes (optional)',
                              border: OutlineInputBorder()),
                          maxLines: 3,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: ctrls['youtube'],
                          decoration: InputDecoration(
                              labelText: 'YouTube Link (optional)',
                              border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                final removed =
                                    _lessonControllers.removeAt(idx);
                                for (var c in removed.values) {
                                  c.dispose();
                                }
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text('Remove',
                                style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _lessonControllers.add({
                        'title': TextEditingController(),
                        'notes': TextEditingController(),
                        'youtube': TextEditingController(),
                      });
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Lesson'),
                ),
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
                          isEditing ? 'Save Changes' : 'Upload Course',
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
