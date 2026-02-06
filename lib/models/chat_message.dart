import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String role; // "user" or "assistant"
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
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

    return ChatMessage(
      id: docId,
      role: map['role'] ?? 'assistant',
      text: map['text'] ?? '',
      createdAt: created,
    );
  }
}
