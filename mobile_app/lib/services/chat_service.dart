import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:synapse/services/storage_service.dart';

const String baseUrl = 'http://34.131.111.20:8000';

class ChatService {
  static Future<String> sendMessage(String message) async {
    final url = Uri.parse("$baseUrl/chat");

    final token = await StorageService.getToken();

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // CRITICAL
          },
          body: jsonEncode({
            "message": message,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["response"];
    } else {
      throw Exception("Server error");
    }
  }
}
