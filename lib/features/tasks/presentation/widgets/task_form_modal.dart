import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_date_format.dart';
import '../../../todo_lists/data/models/todo_list_response_dto.dart';
import '../../../todo_lists/domain/repositories/todo_lists_repository.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../../domain/entities/todo_item_enums.dart';
import '../../domain/repositories/todo_items_repository.dart';
import '../cubits/task_form_cubit.dart';
import '../cubits/task_form_state.dart';

class TaskFormModal extends StatefulWidget {
  final TodoItemResponseDto? initialTask;
  final String? preselectedTodoListId;

  const TaskFormModal({
    super.key,
    this.initialTask,
    this.preselectedTodoListId,
  });

  static Future<TodoItemResponseDto?> show(
    BuildContext context, {
    TodoItemResponseDto? task,
    String? preselectedTodoListId,
  }) {
    final tasksRepo = context.read<TodoItemsRepository>();
    final listsRepo = context.read<TodoListsRepository>();

    return showModalBottomSheet<TodoItemResponseDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: tasksRepo),
          RepositoryProvider.value(value: listsRepo),
        ],
        child: BlocProvider(
          create: (_) => TaskFormCubit(repository: tasksRepo)
            ..initializeForCreate(
              preselectedTodoListId: preselectedTodoListId,
            ),
          child: TaskFormModal(
            initialTask: task,
            preselectedTodoListId: preselectedTodoListId,
          ),
        ),
      ),
    );
  }

  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();
  List<TodoListResponseDto> _availableLists = [];
  bool _loadingLists = true;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (task != null) {
        context.read<TaskFormCubit>().initializeForEdit(task);
      } else if (widget.preselectedTodoListId != null) {
        context.read<TaskFormCubit>().initializeForCreate(
              preselectedTodoListId: widget.preselectedTodoListId,
            );
      }
      _fetchAvailableLists();
    });
  }

  Future<void> _fetchAvailableLists() async {
    try {
      final lists = await context.read<TodoListsRepository>().getTodoLists();
      if (mounted) {
        setState(() {
          _availableLists = lists;
          _loadingLists = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingLists = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(DateTime? current) async {
    final now = DateTime.now();
    final initial = current ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!mounted) return;
    context.read<TaskFormCubit>().dueDateChanged(combined);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<TaskFormCubit, TaskFormState>(
      listener: (context, state) {
        if (state.status == TaskFormStatus.success) {
          Navigator.of(context).pop(state.resultTask);
        } else if (state.status == TaskFormStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final isEditing = state.isEditing;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomInset + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Text(
                    isEditing ? 'Görevi Düzenle' : 'Yeni Görev Oluştur',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    autofocus: !isEditing,
                    decoration: InputDecoration(
                      labelText: 'Görev Başlığı *',
                      hintText: 'Örn. Rapor hazırla',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) =>
                        context.read<TaskFormCubit>().titleChanged(val),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Başlık boş bırakılamaz';
                      }
                      if (val.trim().length > 200) {
                        return 'Başlık en fazla 200 karakter olabilir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Description field
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (İsteğe bağlı)',
                      hintText: 'Detayları buraya ekleyin...',
                      prefixIcon: const Icon(Icons.notes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) =>
                        context.read<TaskFormCubit>().descriptionChanged(val),
                  ),
                  const SizedBox(height: 16),

                  // Priority Segmented Selector
                  Text(
                    'Öncelik',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<TaskPriority>(
                    segments: const [
                      ButtonSegment(
                        value: TaskPriority.low,
                        label: Text('Düşük', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: TaskPriority.medium,
                        label: Text('Orta', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: TaskPriority.high,
                        label: Text('Yüksek', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: TaskPriority.urgent,
                        label: Text('Acil', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {state.priority},
                    onSelectionChanged: (newSelection) {
                      context
                          .read<TaskFormCubit>()
                          .priorityChanged(newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Due Date & Time Picker
                  Text(
                    'Bitiş Tarihi & Saati',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _pickDateTime(state.dueDate),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.dueDate != null
                                  ? AppDateFormat.formatDateTime(state.dueDate)
                                  : 'Tarih seçin...',
                              style: TextStyle(
                                color: state.dueDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (state.dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                context
                                    .read<TaskFormCubit>()
                                    .dueDateChanged(null);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TodoList Dropdown
                  Text(
                    'Bağlı Olduğu Liste',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingLists)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<String?>(
                      initialValue: state.todoListId,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.folder_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      hint: const Text('Liste seçilmedi (Genel)'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Liste Yok (Genel)'),
                        ),
                        ..._availableLists.map(
                          (list) => DropdownMenuItem<String?>(
                            value: list.id,
                            child: Text(list.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        context.read<TaskFormCubit>().todoListIdChanged(val);
                      },
                    ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: state.status == TaskFormStatus.submitting
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context.read<TaskFormCubit>().submit();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.status == TaskFormStatus.submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Değişiklikleri Kaydet' : 'Görevi Oluştur',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
