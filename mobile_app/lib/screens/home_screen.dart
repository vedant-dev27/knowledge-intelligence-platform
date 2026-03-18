import 'package:flutter/material.dart';
import 'package:synapse/screens/login_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:synapse/models/message_model.dart';
import 'package:synapse/widgets/app_drawer.dart';
import 'package:synapse/widgets/bot_bubble.dart';
import 'package:synapse/widgets/user_bubble.dart';
import 'package:synapse/widgets/typing_indicator.dart';
import 'package:synapse/services/chat_service.dart';
import 'package:synapse/models/chat_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final chatControl = TextEditingController();
  final box = Hive.box<ChatSession>('chats');
  ChatSession? activeSession;
  bool isTyping = false;

  @override
  void dispose() {
    chatControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: AppDrawer(
        onNewChat: () {
          setState(() => activeSession = null);
          Navigator.pop(context);
        },
        onSessionSelected: (session) {
          setState(() => activeSession = session);
        },
      ),
      drawerEdgeDragWidth: screenWidth,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Synapse",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'auth_token');
                  await box.clear();
                  setState(() => activeSession = null);
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Expanded(
              child: activeSession == null
                  ? const Center(
                      child: Text(
                        "Search your knowledge base",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount:
                          activeSession!.messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isTyping && index == 0) {
                          return const TypingIndicator();
                        }

                        final msg = activeSession!
                            .messages[isTyping ? index - 1 : index];

                        return msg.isbot
                            ? BotBubble(message: msg.text)
                            : UserBubble(message: msg.text);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(52, 158, 158, 158),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  controller: chatControl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Ask Recall",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final messageText = chatControl.text;
                        if (messageText.trim().isEmpty) return;

                        if (activeSession == null) {
                          final newSession = ChatSession(
                            id: const Uuid().v4(),
                            title: messageText,
                            messages: [],
                          );
                          box.put(newSession.id, newSession);
                          setState(() => activeSession = newSession);
                        }

                        setState(() {
                          activeSession!.messages.insert(
                            0,
                            MessageModel(text: messageText, isbot: false),
                          );
                          box.put(activeSession!.id, activeSession!);
                          isTyping = true;
                        });

                        chatControl.clear();

                        try {
                          final reply =
                              await ChatService.sendMessage(messageText);
                          setState(() {
                            isTyping = false;
                            activeSession!.messages.insert(
                              0,
                              MessageModel(text: reply, isbot: true),
                            );
                            box.put(activeSession!.id, activeSession!);
                          });
                        } catch (e) {
                          setState(() {
                            isTyping = false;
                            activeSession!.messages.insert(
                              0,
                              MessageModel(
                                text: "Something went wrong. Please try again.",
                                isbot: true,
                              ),
                            );
                            box.put(activeSession!.id, activeSession!);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
