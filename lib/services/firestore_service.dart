import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makeit/models/course_model.dart';

// Firestore helper for courses and enrollments
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload course: returns created doc id
  Future<String> uploadCourse(Course course) async {
    final docRef = await _db.collection('courses').add({
      'title': course.title,
      'description': course.description,
      'mentorId': course.mentorId,
      'mentorName': course.mentorName,
      'imageUrl': course.imageUrl,
      'price': course.price,
      'enrolledCount': 0,
      'enrolledUsers': <String>[],
      'createdAt': Timestamp.fromDate(course.createdAt),
      'tags': course.tags,
    });
    return docRef.id;
  }

  // Stream all courses (real-time)
  Stream<List<Course>> getCoursesStream() {
    return _db
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Course.fromMap(d.data(), d.id)).toList(),
        );
  }

  // Stream a single course by id
  Stream<Course?> getCourseStream(String courseId) {
    return _db.collection('courses').doc(courseId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Course.fromMap(doc.data()!, doc.id);
    });
  }

  // One-off fetch
  Future<Course?> getCourse(String courseId) async {
    final doc = await _db.collection('courses').doc(courseId).get();
    if (!doc.exists) return null;
    return Course.fromMap(doc.data()!, doc.id);
  }

  // Enroll current user in a course (atomic)
  Future<void> enrollInCourse(String courseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = _db.collection('courses').doc(courseId);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception('Course not found');

      final data = snapshot.data(); // safe read
      final enrolled = data != null && data['enrolledUsers'] != null
          ? List<String>.from(data['enrolledUsers'])
          : <String>[];

      if (enrolled.contains(uid)) return; // already enrolled

      tx.update(docRef, {
        'enrolledUsers': FieldValue.arrayUnion([uid]),
        'enrolledCount': FieldValue.increment(1),
      });
    });
  }

  // Unenroll current user
  Future<void> unenrollFromCourse(String courseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = _db.collection('courses').doc(courseId);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) throw Exception('Course not found');

      final data = snapshot.data(); // safe read
      final enrolled = data != null && data['enrolledUsers'] != null
          ? List<String>.from(data['enrolledUsers'])
          : <String>[];

      if (!enrolled.contains(uid)) return; // not enrolled

      tx.update(docRef, {
        'enrolledUsers': FieldValue.arrayRemove([uid]),
        'enrolledCount': FieldValue.increment(-1),
      });
    });
  }

  // Helper: check if current user is enrolled (one-off)
  Future<bool> isUserEnrolled(String courseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('courses').doc(courseId).get();
    if (!doc.exists) return false;
    final data = doc.data(); // safe read
    final enrolled = data != null && data['enrolledUsers'] != null
        ? List<String>.from(data['enrolledUsers'])
        : <String>[];
    return enrolled.contains(uid);
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _db.collection('courses').doc(courseId).delete();
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }
}
