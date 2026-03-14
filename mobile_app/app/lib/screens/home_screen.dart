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
  final List<MessageModel> messageList = [
    MessageModel(
        text: "Hello! I'm Recall. How can I help you today?", isbot: true),
    MessageModel(
        text: "Explain the four laws of thermodynamics.", isbot: false),
    MessageModel(
        text:
            "The four laws of thermodynamics describe fundamental physical principles governing energy and heat.",
        isbot: true),
    MessageModel(text: "Can you summarize them briefly?", isbot: false),
    MessageModel(
        text:
            "Sure!\n\nZeroth Law: If two systems are in thermal equilibrium with a third, they are in equilibrium with each other.\n\nFirst Law: Energy cannot be created or destroyed, only transferred or transformed.\n\nSecond Law: Entropy of an isolated system always increases.\n\nThird Law: As temperature approaches absolute zero, entropy approaches a constant minimum.",
        isbot: true),
    MessageModel(text: "Nice. Give me a real-world example.", isbot: false),
    MessageModel(
        text:
            "A refrigerator works using thermodynamic principles. It transfers heat from inside the fridge to the surrounding environment using energy from electricity.",
        isbot: true),
  ];
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
