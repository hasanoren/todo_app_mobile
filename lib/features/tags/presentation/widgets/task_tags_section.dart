import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/tags_repository.dart';
import '../cubits/task_tags_cubit.dart';
import '../cubits/task_tags_state.dart';
import '../../data/models/tag_response_dto.dart';
import '../screens/tagged_tasks_screen.dart';
import 'tag_chip.dart';
import 'tag_selector_bottom_sheet.dart';

class TaskTagsSection extends StatefulWidget {
  final String taskId;
  final bool isOwner;
  final List<TagResponseDto>? initialTags;

  const TaskTagsSection({
    super.key,
    required this.taskId,
    required this.isOwner,
    this.initialTags,
  });

  @override
  State<TaskTagsSection> createState() => _TaskTagsSectionState();
}

class _TaskTagsSectionState extends State<TaskTagsSection> {
  late TaskTagsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TaskTagsCubit(
      tagsRepository: context.read<TagsRepository>(),
      taskId: widget.taskId,
      initialTags: widget.initialTags,
    );

    if (widget.initialTags == null) {
      _cubit.loadTags();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openTagSelector() {
    TagSelectorBottomSheet.show(
      context,
      taskTagsCubit: _cubit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<TaskTagsCubit, TaskTagsState>(
        listener: (context, state) {
          if (state is TaskTagsLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          final tags = state is TaskTagsLoaded ? state.tags : <TagResponseDto>[];
          final isLoading = state is TaskTagsLoading;
          final isAttaching = state is TaskTagsLoaded && state.isAttaching;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.label_outline,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Etiketler',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (tags.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tags.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.isOwner)
                        TextButton.icon(
                          onPressed: _openTagSelector,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Etiket Ekle'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tag Chips or Empty / Loading
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (tags.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: widget.isOwner
                          ? InkWell(
                              onTap: _openTagSelector,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Etiket eklemek için dokunun',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              'Bu göreve atanmış etiket bulunmuyor.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...tags.map((tag) {
                          final isDetaching = state is TaskTagsLoaded &&
                              state.detachingTagId == tag.id;

                          if (isDetaching) {
                            return const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          return TagChip(
                            name: tag.name,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaggedTasksScreen(tag: tag),
                                ),
                              );
                            },
                            onDeleted: widget.isOwner
                                ? () => _cubit.detachTag(tag.id)
                                : null,
                          );
                        }),
                        if (isAttaching)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

