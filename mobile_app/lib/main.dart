import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synapse/screens/loading_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:synapse/models/message_model.dart';
import 'package:synapse/models/chat_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ChatSessionAdapter());
  await Hive.openBox<ChatSession>('chats');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const LoadingScreen(),
    );
  }
}
