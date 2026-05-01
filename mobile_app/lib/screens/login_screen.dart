import 'package:flutter/material.dart';
import 'package:synapse/screens/home_screen.dart';
import 'register_page.dart';
import 'package:synapse/widgets/input_field.dart';
import 'package:synapse/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final uidController = TextEditingController();
  final pwdController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              Text(
                "Welcome \nback",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your knowledge assistant is waiting.",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
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
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isLoading) return;
                    setState(() => isLoading = true);

                    final res = await AuthService.loginUser(
                      uidController.text,
                      pwdController.text,
                    );

                    if (res) {
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    } else {
                      uidController.clear();
                      pwdController.clear();
                      setState(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      InkWell(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
