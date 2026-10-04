import 'package:flutter/material.dart';

class ShareTaskDialog extends StatefulWidget {
  final Future<bool> Function(String email) onShare;

  const ShareTaskDialog({super.key, required this.onShare});

  static Future<void> show(
    BuildContext context, {
    required Future<bool> Function(String email) onShare,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ShareTaskDialog(onShare: onShare),
    );
  }

  @override
  State<ShareTaskDialog> createState() => _ShareTaskDialogState();
}

class _ShareTaskDialogState extends State<ShareTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi gereklidir';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await widget.onShare(_emailController.text.trim());
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Görevi Paylaş'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Görevi birlikte takip etmek istediğiniz kullanıcının e-posta adresini girin.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı E-postası',
                hintText: 'ornek@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: _validateEmail,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Paylaş'),
        ),
      ],
    );
  }
}

