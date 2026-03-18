import 'package:flutter/material.dart';
import 'package:synapse/screens/home_screen.dart';
import 'package:synapse/screens/login_screen.dart';
import 'package:synapse/services/auth_service.dart';
import 'package:synapse/services/storage_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkToken();
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> checkToken() async {
    try {
      final token = await StorageService.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (token == null) {
        _goTo(const LoginPage());
        return;
      }

      final isValid = await AuthService.validateUser(token).timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );

      if (!mounted) return;

      _goTo(isValid ? const HomeScreen() : const LoginPage());
    } catch (e) {
      debugPrint('checkToken error: $e');
      if (mounted) _goTo(const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Synapse",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Your knowledge, ready",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
