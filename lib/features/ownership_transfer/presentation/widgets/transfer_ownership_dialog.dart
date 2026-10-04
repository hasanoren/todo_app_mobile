import 'package:flutter/material.dart';

class TransferOwnershipDialog extends StatefulWidget {
  final Future<bool> Function(String email) onTransfer;

  const TransferOwnershipDialog({super.key, required this.onTransfer});

  static Future<void> show(
    BuildContext context, {
    required Future<bool> Function(String email) onTransfer,
  }) {
    return showDialog(
      context: context,
      builder: (_) => TransferOwnershipDialog(onTransfer: onTransfer),
    );
  }

  @override
  State<TransferOwnershipDialog> createState() =>
      _TransferOwnershipDialogState();
}

class _TransferOwnershipDialogState extends State<TransferOwnershipDialog> {
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
      return 'Yeni sahibin e-posta adresi gereklidir';
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
    final success = await widget.onTransfer(_emailController.text.trim());
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
      title: const Text('Görevin Sahipliğini Devret'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Görevin tam sahipliğini devretmek istediğiniz kullanıcının e-posta adresini girin. '
              'Kullanıcı isteği kabul ettiğinde görevin yeni sahibi olacaktır.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Yeni Sahibin E-postası',
                hintText: 'yeni_sahip@example.com',
                prefixIcon: Icon(Icons.person_outline),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Devir İsteği Gönder'),
        ),
      ],
    );
  }
}

