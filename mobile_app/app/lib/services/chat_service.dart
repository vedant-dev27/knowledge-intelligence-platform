import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  static const String _backendUrl = 'http://192.168.0.169:8000/chat';
  late final http.Client _client;

  ChatService() {
    _client = http.Client();
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _client.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response from backend.';
      } else {
        return 'Backend error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
