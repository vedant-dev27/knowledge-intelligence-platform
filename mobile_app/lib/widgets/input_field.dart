import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator; // added

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator, // added
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextFormField(
          // changed
          controller: controller,
          obscureText: obscureText,
          validator: validator, // added
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 20,
            height: 1.2,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.hintColor,
            ),
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                icon,
                color: theme.iconTheme.color,
              ),
            ),
            suffixIcon: suffixIcon,
            prefixIconConstraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 24,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
