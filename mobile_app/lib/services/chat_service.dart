import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl =
    'https://nondirectional-babette-devastatingly.ngrok-free.dev';

class ChatService {
  static Future<String> sendMessage(String message) async {
    final url = Uri.parse("$baseUrl/chat");

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "message": message,
          }),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["response"];
    } else {
      throw Exception("Server error");
    }
  }
}
