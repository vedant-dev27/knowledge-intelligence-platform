import 'package:flutter/material.dart';

class RegisterNotification {
  static void show(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text("User created successfully"),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
