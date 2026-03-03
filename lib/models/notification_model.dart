class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    DateTime created = DateTime.now();
    final rawCreated = map['createdAt'];
    try {
      if (rawCreated is DateTime) {
        created = rawCreated;
      } else if (rawCreated is String) {
        created = DateTime.parse(rawCreated);
      } else if (rawCreated != null && rawCreated.toDate != null) {
        created = rawCreated.toDate();
      }
    } catch (_) {}

    return AppNotification(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      read: map['read'] == true,
      createdAt: created,
    );
  }
}
