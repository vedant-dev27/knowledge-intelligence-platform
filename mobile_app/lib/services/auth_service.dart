import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:synapse/services/storage_service.dart';

const String baseUrl = 'http://34.131.111.20:8000';

class AuthService {
  static Future<bool> registerUser(
    String name,
    String uid,
    String pwd,
    String role,
  ) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "name": name, // NEW
            "uid": uid,
            "pwd": pwd,
            "role": role,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return false;

    final decoded = jsonDecode(response.body);
    return decoded["response"] == true;
  }

  static Future<bool> loginUser(String uid, String pwd) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "uid": uid,
            "pwd": pwd,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return false;

    final decoded = jsonDecode(response.body);

    if (decoded["success"] == true) {
      await StorageService.storeToken(decoded["token"]);
      return true;
    }

    return false;
  }

  static Future<Map<String, dynamic>?> validateUser(String token) async {
    final url = Uri.parse("$baseUrl/auth/verify");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) return null;

    return jsonDecode(response.body);
  }
}
