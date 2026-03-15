import 'package:flutter/material.dart';
import 'package:lumina/screens/login_screen.dart';
import 'package:lumina/widgets/input_field.dart';
import 'package:lumina/services/auth_service.dart';
import 'package:lumina/widgets/register_notification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final uidController = TextEditingController();
  final pwdController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const SizedBox(height: 48),
              const Text(
                "Welcome to\nSynapse",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "  Your AI for exploring knowledge.",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6B6B8A),
                ),
              ),
              const SizedBox(height: 36),
              InputField(
                controller: nameController,
                hint: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              InputField(
                controller: uidController,
                hint: "Email",
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 12),
              InputField(
                controller: pwdController,
                hint: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              InputField(
                controller: confirmController,
                hint: "Confirm Password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    String uid = uidController.text;
                    String pwd = pwdController.text;
                    //   String name = nameController.text;

                    uidController.clear();
                    pwdController.clear();
                    nameController.clear();
                    confirmController.clear();
                    bool success = await AuthService.register_user(
                      uid,
                      pwd,
                    );

                    if (success) {
                      RegisterNotification.show(context);
                      await Future.delayed(
                        Duration(
                          seconds: 2,
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF6B6B8A)),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
