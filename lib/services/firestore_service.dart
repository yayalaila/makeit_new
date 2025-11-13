import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makeit/models/course_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload a new course
  Future<String> uploadCourse(Course course) async {
    try {
      final docRef = await _db.collection('courses').add(course.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to upload course: $e');
    }
  }

  // Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      final querySnapshot = await _db.collection('courses').get();
      return querySnapshot.docs
          .map((doc) => Course.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  // Get courses by current mentor
  Future<List<Course>> getMyCourses() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      final querySnapshot = await _db
          .collection('courses')
          .where('mentorId', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map((doc) => Course.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch your courses: $e');
    }
  }

  // Get single course
  Future<Course?> getCourse(String courseId) async {
    try {
      final doc = await _db.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return Course.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  // Update course
  Future<void> updateCourse(String courseId, Course course) async {
    try {
      await _db.collection('courses').doc(courseId).update(course.toMap());
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _db.collection('courses').doc(courseId).delete();
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // Stream courses (real-time updates)
  Stream<List<Course>> getCoursesStream() {
    return _db.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Course.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
