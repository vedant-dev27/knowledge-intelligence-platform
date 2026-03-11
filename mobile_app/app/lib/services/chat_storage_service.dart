import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

class ChatStorageService {
  static const String _boxName = 'chat_messages';

  Box<ChatMessage>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<ChatMessage>(_boxName);
  }

  List<ChatMessage> loadMessages() {
    return _box?.values.toList() ?? [];
  }

  Future<void> saveMessage(ChatMessage message) async {
    await _box?.add(message);
  }

  Future<void> clearAll() async {
    await _box?.clear();
  }

  int get messageCount => _box?.length ?? 0;
}
