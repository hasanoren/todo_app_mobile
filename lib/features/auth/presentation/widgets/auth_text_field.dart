import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String? errorText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? hintText;

  const AuthTextField({
    super.key,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
