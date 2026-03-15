import 'package:flutter/material.dart';

class RegisterNotification {
  static void show(BuildContext context) {
    const snackBar = SnackBar(
      content: Text("User created successfully"),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
