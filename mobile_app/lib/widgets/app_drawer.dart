import 'package:flutter/material.dart';
import 'package:synapse/widgets/dataset_menu_button.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:synapse/models/chat_session.dart';
import 'package:synapse/widgets/new_chat_button.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
    required this.onSessionSelected,
    required this.onNewChat,
  });
  final Function(ChatSession) onSessionSelected;
  final VoidCallback onNewChat;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "Synapse",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      "v0.5.1",
                    ),
                  ],
                ),
                const Text("Designed by Vedant Singh"),
                const SizedBox(
                  height: 10,
                ),
                const DatasetMenuButton(),
                NewChatButton(
                  onTap: widget.onNewChat,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Text(
                    "Recents",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: Hive.box<ChatSession>('chats').listenable(),
                  builder: (context, Box<ChatSession> box, _) {
                    final sessions = box.values.toList();
                    return Column(
                      children: sessions
                          .map(
                            (session) => ListTile(
                              title: Text(
                                session.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                widget.onSessionSelected(session);
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
