import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/subtask_response_dto.dart';
import '../../domain/repositories/subtasks_repository.dart';
import '../cubits/subtasks_cubit.dart';
import '../cubits/subtasks_state.dart';
import 'subtask_item_tile.dart';

class SubtasksSection extends StatelessWidget {
  final String taskId;
  final bool isOwner;
  final List<SubtaskResponseDto>? initialSubtasks;

  const SubtasksSection({
    super.key,
    required this.taskId,
    required this.isOwner,
    this.initialSubtasks,
  });

  @override
  Widget build(BuildContext context) {
    final subtasksRepo = context.read<SubtasksRepository>();

    return BlocProvider(
      create: (_) {
        final cubit = SubtasksCubit(repository: subtasksRepo);
        if (initialSubtasks != null && initialSubtasks!.isNotEmpty) {
          cubit.setInitialItems(initialSubtasks!);
        } else {
          cubit.loadSubtasks(taskId);
        }
        return cubit;
      },
      child: _SubtasksSectionContent(
        taskId: taskId,
        isOwner: isOwner,
      ),
    );
  }
}

class _SubtasksSectionContent extends StatefulWidget {
  final String taskId;
  final bool isOwner;

  const _SubtasksSectionContent({
    required this.taskId,
    required this.isOwner,
  });

  @override
  State<_SubtasksSectionContent> createState() =>
      _SubtasksSectionContentState();
}

class _SubtasksSectionContentState extends State<_SubtasksSectionContent> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onAddSubmitted() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    context.read<SubtasksCubit>().addSubtask(widget.taskId, text);
    _inputController.clear();
  }

  Future<void> _confirmDelete(SubtaskResponseDto subtask) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alt Görevi Sil'),
        content: Text(
          '"${subtask.title}" alt görevini silmek istediğinize emin misiniz?',
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
      context.read<SubtasksCubit>().deleteSubtask(subtask.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SubtasksCubit, SubtasksState>(
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
        final total = state.totalCount;
        final completed = state.completedCount;
        final ratio = state.progressRatio;
        final percentage = (ratio * 100).toInt();

        return Card(
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
                // Header with counts
                Row(
                  children: [
                    const Icon(Icons.checklist, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Alt Görevler ($completed/$total)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (total > 0)
                      Text(
                        '%$percentage',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: completed == total
                              ? Colors.green.shade700
                              : theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress Bar
                if (total > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed == total
                            ? Colors.green.shade600
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // List of subtasks
                if (state.status == SubtasksStatus.loading &&
                    state.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (state.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Henüz alt görev eklenmemiş. Aşağıdan ilk adımı ekleyin.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                else
                  ...state.items.map(
                    (subtask) => SubtaskItemTile(
                      subtask: subtask,
                      isOwner: widget.isOwner,
                      isToggling: state.togglingId == subtask.id,
                      onToggle: () {
                        context
                            .read<SubtasksCubit>()
                            .toggleComplete(subtask.id);
                      },
                      onDelete: () => _confirmDelete(subtask),
                    ),
                  ),

                const SizedBox(height: 12),
                const Divider(),

                // Quick add row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onAddSubmitted(),
                        decoration: InputDecoration(
                          hintText: 'Yeni alt görev ekle...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: state.isAdding ? null : _onAddSubmitted,
                      icon: state.isAdding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

