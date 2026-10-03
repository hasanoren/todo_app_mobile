import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? errorText;
  final bool obscureText;
  final bool isPassword;
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
    this.isPassword = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.controller,
    this.hintText,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword || widget.obscureText;
  }

  bool get _isPasswordField => widget.isPassword || widget.obscureText;

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffixIcon = widget.suffixIcon;
    if (_isPasswordField && effectiveSuffixIcon == null) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.outline,
        ),
        tooltip: _obscured ? 'Şifreyi Göster' : 'Şifreyi Gizle',
        onPressed: () {
          setState(() {
            _obscured = !_obscured;
          });
        },
      );
    }

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: _isPasswordField ? _obscured : widget.obscureText,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        suffixIcon: effectiveSuffixIcon,
      ),
    );
  }
}
