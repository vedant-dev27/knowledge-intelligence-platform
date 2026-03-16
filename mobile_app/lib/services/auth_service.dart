import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:synapse/services/storage_service.dart';

const String baseUrl =
    'https://nondirectional-babette-devastatingly.ngrok-free.dev';

class AuthService {
  static Future<bool> registerUser(String uid, String pwd) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(
            {"uid": uid, "pwd": pwd},
          ),
        )
        .timeout(
          const Duration(seconds: 5),
        );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded["response"];
    } else {
      return false;
    }
  }

  static Future<bool> loginUser(String uid, String pwd) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(
            {"uid": uid, "pwd": pwd},
          ),
        )
        .timeout(
          const Duration(seconds: 5),
        );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded["success"]) {
        await StorageService.storeToken(decoded["token"]);
      }
      return decoded["success"];
    } else {
      return false;
    }
  }

  static Future<bool> validateUser(String token) async {
    final url = Uri.parse("$baseUrl/auth/verify");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
