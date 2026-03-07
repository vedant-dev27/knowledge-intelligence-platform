import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:rag_chat/models/chat_message.dart';
import 'package:rag_chat/services/chat_storage_service.dart';
import 'package:rag_chat/services/gemini_service.dart';
import 'package:rag_chat/screens/chat_screen.dart';

const String geminiApiKey = 'AIzaSyCyJbMnsnE78NNtOWDTdAUwFxsEpvdeqYk';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageAdapter());

  
  final storageService = ChatStorageService();
  await storageService.init();

  
  final geminiService = GeminiService(geminiApiKey);

  runApp(RagChatApp(
    storageService: storageService,
    geminiService: geminiService,
  ));
}

class RagChatApp extends StatelessWidget {
  final ChatStorageService storageService;
  final GeminiService geminiService;

  const RagChatApp({
    super.key,
    required this.storageService,
    required this.geminiService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAG Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: ChatScreen(
        storageService: storageService,
        geminiService: geminiService,
      ),
    );
  }
}
