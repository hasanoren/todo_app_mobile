import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/profile_cubit.dart';
import '../cubits/system_tags_cubit.dart';
import '../cubits/system_tags_state.dart';
import '../cubits/task_tags_cubit.dart';
import '../cubits/task_tags_state.dart';
import 'create_tag_dialog.dart';

class TagSelectorBottomSheet extends StatefulWidget {
  final TaskTagsCubit taskTagsCubit;
  final bool? isAdmin;

  const TagSelectorBottomSheet({
    super.key,
    required this.taskTagsCubit,
    this.isAdmin,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskTagsCubit taskTagsCubit,
    bool? isAdmin,
  }) {
    final systemTagsCubit = context.read<SystemTagsCubit>();
    ProfileCubit? profileCubit;
    try {
      profileCubit = context.read<ProfileCubit>();
    } catch (_) {}

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: systemTagsCubit),
          BlocProvider.value(value: taskTagsCubit),
          if (profileCubit != null) BlocProvider.value(value: profileCubit),
        ],
        child: TagSelectorBottomSheet(
          taskTagsCubit: taskTagsCubit,
          isAdmin: isAdmin,
        ),
      ),
    );
  }

  @override
  State<TagSelectorBottomSheet> createState() => _TagSelectorBottomSheetState();
}

class _TagSelectorBottomSheetState extends State<TagSelectorBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load system tags if initial
    final systemCubit = context.read<SystemTagsCubit>();
    if (systemCubit.state is SystemTagsInitial) {
      systemCubit.loadSystemTags();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _checkIsAdmin(BuildContext context) {
    if (widget.isAdmin != null) return widget.isAdmin!;
    try {
      final profileState = context.read<ProfileCubit>().state;
      return profileState.profile?.role.toLowerCase() == 'admin';
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = _checkIsAdmin(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.label, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      'Etiketleri Yönet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isAdmin)
                  TextButton.icon(
                    onPressed: () async {
                      final newTag = await CreateTagDialog.show(context);
                      if (newTag != null && mounted) {
                        widget.taskTagsCubit.attachTag(newTag);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Yeni Etiket'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Etiket ara...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),
            const SizedBox(height: 16),

            // Tag List Content
            Expanded(
              child: BlocBuilder<SystemTagsCubit, SystemTagsState>(
                builder: (context, systemState) {
                  if (systemState is SystemTagsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (systemState is SystemTagsFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade400, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            systemState.message,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context
                                .read<SystemTagsCubit>()
                                .loadSystemTags(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    );
                  }

                  final allTags = systemState is SystemTagsLoaded
                      ? systemState.tags
                      : <dynamic>[];

                  final filteredTags = allTags.where((t) {
                    if (_searchQuery.isEmpty) return true;
                    return t.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredTags.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Sistemde henüz etiket bulunmuyor.'
                              : 'Eşleşen etiket bulunamadı.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  return BlocBuilder<TaskTagsCubit, TaskTagsState>(
                    bloc: widget.taskTagsCubit,
                    builder: (context, taskState) {
                      final attachedTagIds = taskState is TaskTagsLoaded
                          ? taskState.tags.map((t) => t.id).toSet()
                          : <String>{};

                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredTags.map((tag) {
                            final isAttached = attachedTagIds.contains(tag.id);

                            return FilterChip(
                              label: Text(tag.name),
                              selected: isAttached,
                              onSelected: (selected) {
                                if (selected) {
                                  widget.taskTagsCubit.attachTag(tag);
                                } else {
                                  widget.taskTagsCubit.detachTag(tag.id);
                                }
                              },
                              selectedColor:
                                  Colors.indigo.withValues(alpha: 0.2),
                              checkmarkColor: Colors.indigo,
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(
                                color: isAttached
                                    ? Colors.indigo.shade900
                                    : Colors.grey.shade800,
                                fontWeight: isAttached
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isAttached
                                      ? Colors.indigo
                                      : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Done Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
