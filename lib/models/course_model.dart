class Course {
  final String id;
  final String title;
  final String description;
  final String mentorId;
  final String mentorName;
  final String? imageUrl;
  final double price;
  final int enrolledCount;
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
    required this.createdAt,
    this.tags = const [],
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'imageUrl': imageUrl,
      'price': price,
      'enrolledCount': enrolledCount,
      'createdAt': createdAt,
      'tags': tags,
    };
  }

  // Create from Firestore document
  factory Course.fromMap(Map<String, dynamic> map, String docId) {
    return Course(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      imageUrl: map['imageUrl'],
      price: (map['price'] ?? 0).toDouble(),
      enrolledCount: map['enrolledCount'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
