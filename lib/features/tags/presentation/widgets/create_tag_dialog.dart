import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/system_tags_cubit.dart';
import '../cubits/system_tags_state.dart';
import '../../data/models/tag_response_dto.dart';

class CreateTagDialog extends StatefulWidget {
  const CreateTagDialog({super.key});

  static Future<TagResponseDto?> show(BuildContext context) {
    final systemTagsCubit = context.read<SystemTagsCubit>();
    return showDialog<TagResponseDto>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: systemTagsCubit,
        child: const CreateTagDialog(),
      ),
    );
  }

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<SystemTagsCubit>();
    final newTag = await cubit.createTag(_controller.text.trim());
    if (newTag != null && mounted) {
      Navigator.of(context).pop(newTag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SystemTagsCubit, SystemTagsState>(
      listener: (context, state) {
        if (state is SystemTagsLoaded && state.createError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createError!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final isCreating = state is SystemTagsLoaded && state.isCreating;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.label_outline, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                'Yeni Etiket Oluştur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              autofocus: true,
              enabled: !isCreating,
              decoration: InputDecoration(
                labelText: 'Etiket Adı',
                hintText: 'Örn. Frontend, Backend, UI/UX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.tag),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Lütfen bir etiket adı girin';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isCreating ? null : _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }
}

