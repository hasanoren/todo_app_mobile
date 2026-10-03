import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_date_format.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../cubits/task_detail_cubit.dart';
import '../cubits/task_detail_state.dart';
import '../widgets/priority_badge.dart';
import '../widgets/task_form_modal.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskDetailCubit>().loadTask(widget.taskId);
    });
  }

  Future<void> _openEditModal(TodoItemResponseDto task) async {
    final updated = await TaskFormModal.show(context, task: task);
    if (updated != null && mounted) {
      context.read<TaskDetailCubit>().onTaskUpdated(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${updated.title}" güncellendi.'),
          backgroundColor: Colors.blue.shade700,
        ),
      );
    }
  }

  Future<void> _confirmDelete(TodoItemResponseDto task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text(
          '"${task.title}" görevini silip çöp kutusuna taşımak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<TaskDetailCubit>().deleteTask();
      if (success && mounted) {
        Navigator.of(context).pop('deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<TaskDetailCubit, TaskDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final task = state.task;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            // Task can be returned to update the list view
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Görev Detayı'),
              actions: [
                if (task != null && task.isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Düzenle',
                    onPressed: () => _openEditModal(task),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade600,
                    ),
                    tooltip: 'Sil',
                    onPressed: () => _confirmDelete(task),
                  ),
                ],
              ],
            ),
            body: Builder(
              builder: (context) {
                if (state.status == TaskDetailStatus.loading && task == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TaskDetailStatus.error && task == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 54,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ?? 'Detaylar yüklenemedi.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<TaskDetailCubit>()
                                .loadTask(widget.taskId),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (task == null) {
                  return const SizedBox.shrink();
                }

                final isCompleted = task.isCompleted;
                final isOverdue = task.isOverdue;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status card with toggle
                      Card(
                        elevation: 0,
                        color: isCompleted
                            ? Colors.green.shade50
                            : theme.colorScheme.primary.withValues(alpha: 0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isCompleted
                                ? Colors.green.shade200
                                : theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: InkWell(
                          onTap: task.isOwner
                              ? () => context
                                  .read<TaskDetailCubit>()
                                  .toggleComplete()
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                if (state.isToggling)
                                  const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted
                                          ? Colors.green.shade600
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isCompleted
                                            ? Colors.green.shade600
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isCompleted
                                        ? const Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isCompleted
                                            ? 'Tamamlandı'
                                            : 'Yapılacak (Açık)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isCompleted
                                              ? Colors.green.shade800
                                              : theme.colorScheme.primary,
                                        ),
                                      ),
                                      if (task.isOwner)
                                        Text(
                                          'Durumu değiştirmek için dokunun',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        task.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey.shade600 : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      if (task.description != null &&
                          task.description!.trim().isNotEmpty) ...[
                        Card(
                          elevation: 0,
                          color: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              task.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Metadata properties
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            children: [
                              _buildMetaRow(
                                context,
                                icon: Icons.flag_outlined,
                                label: 'Öncelik',
                                valueWidget: PriorityBadge(
                                  priority: task.taskPriority,
                                ),
                              ),
                              const Divider(height: 20),
                              _buildMetaRow(
                                context,
                                icon: Icons.calendar_today_outlined,
                                label: 'Bitiş Tarihi',
                                valueText: task.dueDate != null
                                    ? AppDateFormat.formatDateTime(task.dueDate)
                                    : 'Belirtilmedi',
                                isAlert: isOverdue,
                              ),
                              const Divider(height: 20),
                              _buildMetaRow(
                                context,
                                icon: Icons.access_time,
                                label: 'Oluşturulma',
                                valueText: AppDateFormat.formatDateTime(
                                  task.createdAt,
                                ),
                              ),
                              if (task.updatedAt != null) ...[
                                const Divider(height: 20),
                                _buildMetaRow(
                                  context,
                                  icon: Icons.update,
                                  label: 'Son Güncelleme',
                                  valueText: AppDateFormat.formatDateTime(
                                    task.updatedAt,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subtasks preview (FEAT-07 placeholder)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.checklist, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Alt Görevler (${task.subTasks.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (task.subTasks.isEmpty)
                                Text(
                                  'Henüz alt görev eklenmemiş.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                )
                              else
                                ...task.subTasks.map(
                                  (sub) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          sub.isCompleted
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          size: 18,
                                          color: sub.isCompleted
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            sub.title,
                                            style: TextStyle(
                                              decoration: sub.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: sub.isCompleted
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags preview (FEAT-08 placeholder)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.tag, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Etiketler (${task.tags.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (task.tags.isEmpty)
                                Text(
                                  'Henüz etiket eklenmemiş.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  children: task.tags
                                      .map(
                                        (tag) => Chip(
                                          label: Text(tag.name),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? valueText,
    Widget? valueWidget,
    bool isAlert = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget
        else if (valueText != null)
          Text(
            valueText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isAlert ? Colors.red.shade700 : Colors.black87,
            ),
          ),
      ],
    );
  }
}
