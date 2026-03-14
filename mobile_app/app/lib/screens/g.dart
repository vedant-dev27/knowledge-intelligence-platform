import 'package:flutter/material.dart';

class G extends StatelessWidget {
  const G({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create yyur\naccount.",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Start learning smarter today.",
                style: TextStyle(
                  color: Color(0xFF6B6B8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
