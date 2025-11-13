// Model for Course stored in Firestore
class Course {
  final String id;
  final String title;
  final String description;
  final String mentorId;
  final String mentorName;
  final String? imageUrl;
  final double price;
  final int enrolledCount;
  final List<String> enrolledUsers;
  final DateTime createdAt;
  final List<String> tags;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.mentorId,
    required this.mentorName,
    this.imageUrl,
    required this.price,
    this.enrolledCount = 0,
    this.enrolledUsers = const [],
    required this.createdAt,
    this.tags = const [],
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'imageUrl': imageUrl,
      'price': price,
      'enrolledCount': enrolledCount,
      'enrolledUsers': enrolledUsers,
      'createdAt': createdAt.toUtc(),
      'tags': tags,
    };
  }

  // Create from Firestore document
  factory Course.fromMap(Map<String, dynamic> map, String docId) {
    // createdAt may be Timestamp (from Firestore) or String/DateTime
    DateTime created = DateTime.now();
    final rawCreated = map['createdAt'];
    try {
      if (rawCreated is DateTime) {
        created = rawCreated;
      } else if (rawCreated is String) {
        created = DateTime.parse(rawCreated);
      } else if (rawCreated != null && rawCreated.toDate != null) {
        // Timestamp from Firestore
        created = rawCreated.toDate();
      }
    } catch (_) {}
    return Course(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      imageUrl: map['imageUrl'],
      price: (map['price'] ?? 0).toDouble(),
      enrolledCount: (map['enrolledCount'] ?? 0),
      enrolledUsers: List<String>.from(map['enrolledUsers'] ?? []),
      createdAt: created,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
