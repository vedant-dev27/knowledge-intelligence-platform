import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.0.169:8000';

class UploadService {
  static Future<Map<String, dynamic>> uploadFile(File file) async {
    final uri = Uri.parse('$baseUrl/upload');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw HttpException(
        'Upload failed with status ${response.statusCode}: ${response.reasonPhrase}',
      );
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }
}