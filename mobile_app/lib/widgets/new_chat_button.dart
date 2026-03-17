import 'package:flutter/material.dart';

class NewChatButton extends StatelessWidget {
  const NewChatButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 19,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
              255, 240, 240, 255), // slight tint to differentiate
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.add_comment_rounded),
            SizedBox(width: 10),
            Text(
              "New Chat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
