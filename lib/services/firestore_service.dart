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
      'lessons': course.lessons.map((l) => l.toMap()).toList(),
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
      return Course.fromMap(doc.data() ?? {}, doc.id);
    });
  }

  // One-off fetch
  Future<Course?> getCourse(String courseId) async {
    final doc = await _db.collection('courses').doc(courseId).get();
    if (!doc.exists) return null;
    return Course.fromMap(doc.data() ?? {}, doc.id);
  }

  // Stream today's learned minutes for the current user.
  // Expects a document under `user_stats/{uid}` that may contain either:
  // - a top-level `todayMinutes` number, or
  // - a `dailyMinutes` map with date keys (YYYY-MM-DD) -> number of minutes.
  Stream<int> getTodayLearnedMinutesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    final docRef = _db.collection('user_stats').doc(uid);
    return docRef.snapshots().map((snap) {
      if (!snap.exists) return 0;
      final data = snap.data();
      if (data == null) return 0;

      // Try `dailyMinutes` map
      final today = DateTime.now();
      final key =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (data['dailyMinutes'] is Map &&
          (data['dailyMinutes'] as Map).containsKey(key)) {
        final v = (data['dailyMinutes'] as Map)[key];
        if (v is num) return v.toInt();
      }

      // Fallback to single field `todayMinutes`
      if (data['todayMinutes'] is num) {
        return (data['todayMinutes'] as num).toInt();
      }

      return 0;
    });
  }

  // Increment today's learned minutes for the current user by `minutes`.
  // This writes into `user_stats/{uid}` creating the doc if missing and
  // maintains both `dailyMinutes.<YYYY-MM-DD>` and `todayMinutes` fields.
  Future<void> incrementTodayMinutes(int minutes) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = _db.collection('user_stats').doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final today = DateTime.now();
      final key =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (!snap.exists) {
        tx.set(docRef, {
          'dailyMinutes': {key: minutes},
          'todayMinutes': minutes,
        });
        return;
      }

      final data = snap.data() ?? {};
      int current = 0;
      if (data['dailyMinutes'] is Map &&
          (data['dailyMinutes'] as Map).containsKey(key)) {
        final v = (data['dailyMinutes'] as Map)[key];
        if (v is num) current = v.toInt();
      }

      tx.update(docRef, {
        'dailyMinutes.$key': current + minutes,
        'todayMinutes': FieldValue.increment(minutes),
      });
    });
  }

  // Mark a lesson complete for today. If the lesson wasn't already
  // completed today, increment today's minutes by `minutes` and record
  // the lesson under `completedLessons.<YYYY-MM-DD>.<courseId>` to
  // prevent double-counting.
  Future<bool> markLessonComplete(
      String courseId, String lessonId, int minutes) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = _db.collection('user_stats').doc(uid);
    return await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final today = DateTime.now();
      final key =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (!snap.exists) {
        tx.set(docRef, {
          'dailyMinutes': {key: minutes},
          'todayMinutes': minutes,
          'completedLessons': {
            key: {
              courseId: [lessonId]
            }
          },
        });
        return true;
      }

      final data = snap.data() ?? {};

      // Read existing list for today/course
      List existingForCourse = [];
      if (data['completedLessons'] is Map) {
        final dayMap = (data['completedLessons'] as Map)[key];
        if (dayMap is Map) {
          final lst = dayMap[courseId];
          if (lst is List) existingForCourse = List.from(lst);
        }
      }

      if (existingForCourse.contains(lessonId)) {
        return false; // already completed today
      }

      // add lessonId and update nested path
      existingForCourse.add(lessonId);

      tx.update(docRef, {
        'dailyMinutes.$key': FieldValue.increment(minutes),
        'todayMinutes': FieldValue.increment(minutes),
        'completedLessons.$key.$courseId': existingForCourse,
      });

      return true;
    });
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

  // Update an existing course by id
  Future<void> updateCourse(Course course) async {
    if (course.id.isEmpty) throw Exception('Course id is required for update');
    try {
      await _db.collection('courses').doc(course.id).update({
        'title': course.title,
        'description': course.description,
        'mentorId': course.mentorId,
        'mentorName': course.mentorName,
        'imageUrl': course.imageUrl,
        'price': course.price,
        'tags': course.tags,
        'lessons': course.lessons.map((l) => l.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }
}
