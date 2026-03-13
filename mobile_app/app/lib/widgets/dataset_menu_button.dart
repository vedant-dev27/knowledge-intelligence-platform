import 'package:flutter/material.dart';
import 'package:lumina/screens/upload_screen.dart';

class DatasetMenuButton extends StatelessWidget {
  const DatasetMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);

        Future.delayed(
          const Duration(milliseconds: 200),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadScreen(),
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 19,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.upload_file),
            SizedBox(width: 10),
            Text(
              "Your Uploads",
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
