import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/color_utils.dart';
import '../../data/models/todo_list_response_dto.dart';
import '../../domain/repositories/todo_lists_repository.dart';
import '../cubits/todo_list_form_cubit.dart';
import '../cubits/todo_list_form_state.dart';
import 'color_picker_grid.dart';

class TodoListFormModal extends StatelessWidget {
  const TodoListFormModal({super.key});

  static Future<TodoListResponseDto?> show(
    BuildContext context, {
    TodoListResponseDto? initialList,
    required TodoListsRepository repository,
  }) {
    final formCubit = TodoListFormCubit(
      repository: repository,
      initialList: initialList,
    );

    return showModalBottomSheet<TodoListResponseDto>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: formCubit,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: const TodoListFormModal(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoListFormCubit, TodoListFormState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        if (state.resultList != null) {
          Navigator.of(context).pop(state.resultList);
        }
      },
      builder: (context, state) {
        final cubit = context.read<TodoListFormCubit>();
        final listColor = ColorUtils.fromHex(state.colorCode);

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.isEdit ? 'Listeyi Düzenle' : 'Yeni Görev Listesi',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preview Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: listColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: listColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: listColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.name.trim().isNotEmpty
                            ? state.name.trim()
                            : 'Liste Önizleme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: state.name.trim().isNotEmpty
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name TextField
              TextFormField(
                initialValue: state.name,
                decoration: InputDecoration(
                  labelText: 'Liste Adı',
                  hintText: 'Örn. İş, Kişisel, Alışveriş',
                  errorText: state.nameError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.format_list_bulleted),
                ),
                maxLength: 100,
                onChanged: cubit.nameChanged,
              ),
              const SizedBox(height: 12),

              // Color Picker Section
              Text(
                'Liste Rengi',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ColorPickerGrid(
                selectedHex: state.colorCode,
                onColorSelected: cubit.colorChanged,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: listColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: state.isSubmitting ? null : () => cubit.submit(),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        state.isEdit ? 'Listeyi Güncelle' : 'Listeyi Oluştur',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
