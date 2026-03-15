import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const store = FlutterSecureStorage();

class StorageService {
  static Future<void> storeToken(String token) async {
    await store.write(key: "auth_token", value: token);
  }

  static Future<String?> getToken() async {
    final token = await store.read(key: "auth_token");
    return token;
  }
}
