import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  static Future<String> sendMessage(String message) async {
    final url = Uri.parse("http://192.168.0.169:8000/chat");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message,
      }),
    );

    final decoded = jsonDecode(response.body);
    return decoded["response"];
  }
}
