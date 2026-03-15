import 'package:flutter/material.dart';
import 'package:synapse/models/recent_chat_list.dart';

class RecentChatWidget extends StatelessWidget {
  const RecentChatWidget({super.key, required this.chat});

  final RecentChats chat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        child: Text(
          chat.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
