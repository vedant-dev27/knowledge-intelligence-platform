import 'package:flutter/material.dart';
import 'package:synapse/screens/login_screen.dart';
import 'package:synapse/widgets/input_field.dart';
import 'package:synapse/services/auth_service.dart';

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

  bool isLoading = false;

  String selectedRole = 'intern'; // NEW

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
              const SizedBox(height: 32),
              const SizedBox(height: 48),
              Text(
                "Welcome to\nSynapse",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your AI for exploring knowledge.",
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onSurfaceVariant,
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
              const SizedBox(height: 12),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    isExpanded: true,
                    items: ['intern', 'employee', 'admin']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role, // no caps
                                style: TextStyle(
                                  fontSize: 20,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedRole = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Select Role",
                      hintStyle: TextStyle(
                        color: theme.hintColor,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.person_outline,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minHeight: 24,
                        minWidth: 24,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.iconTheme.color,
                    ),
                    dropdownColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isLoading) return;

                    if (pwdController.text != confirmController.text) {
                      return;
                    }

                    setState(() => isLoading = true);

                    final uid = uidController.text;
                    final pwd = pwdController.text;

                    final success = await AuthService.registerUser(
                      uid,
                      pwd,
                      selectedRole, // UPDATED
                    );

                    if (!mounted) return;

                    if (success) {
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    } else {
                      setState(() => isLoading = false);
                    }

                    uidController.clear();
                    pwdController.clear();
                    nameController.clear();
                    confirmController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: theme.colorScheme.primary,
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
