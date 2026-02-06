import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatService {
  // TODO: Set your backend endpoint (Cloud Function / server).
  // Example: https://us-central1-your-project.cloudfunctions.net/aiChat
  static const String kAiEndpoint = '';

  Future<String> getReply({required String prompt}) async {
    if (kAiEndpoint.isEmpty) {
      return 'AI service is not configured yet. Connect your backend endpoint to enable real answers.';
    }

    final response = await http.post(
      Uri.parse(kAiEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode != 200) {
      throw Exception('AI service error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final reply = data['reply'];
    if (reply is String && reply.isNotEmpty) return reply;
    return 'Sorry, I could not generate a reply.';
  }
}
