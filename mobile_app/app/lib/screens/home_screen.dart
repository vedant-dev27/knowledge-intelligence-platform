import 'package:flutter/material.dart';
import 'package:lumina/models/message_model.dart';
import 'package:lumina/widgets/app_drawer.dart';
import 'package:lumina/widgets/bot_bubble.dart';
import 'package:lumina/widgets/user_bubble.dart';
import 'package:lumina/widgets/typing_indicator.dart';
import 'package:lumina/services/chat_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final chatControl = TextEditingController();
  final List<MessageModel> messageList = [];
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
      drawer: AppDrawer(),
      drawerEdgeDragWidth: screenWidth,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Recall",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: messageList.isEmpty && !isTyping
                  ? const Center(
                      child: Text(
                        "Search your knowledge base",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: messageList.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Typing indicator slot
                        if (isTyping && index == 0) {
                          return const TypingIndicator();
                        }

                        final msg = messageList[isTyping ? index - 1 : index];

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

                        // Add user message
                        setState(() {
                          messageList.insert(
                            0,
                            MessageModel(text: messageText, isbot: false),
                          );
                          isTyping = true;
                        });

                        chatControl.clear();

                        try {
                          final reply =
                              await ChatService.sendMessage(messageText);

                          setState(() {
                            isTyping = false;

                            messageList.insert(
                              0,
                              MessageModel(text: reply, isbot: true),
                            );
                          });
                        } catch (e) {
                          setState(() {
                            isTyping = false;

                            messageList.insert(
                              0,
                              MessageModel(
                                text: "Something went wrong. Please try again.",
                                isbot: true,
                              ),
                            );
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
