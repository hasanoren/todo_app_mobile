import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../data/models/todo_item_filter_dto.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../../domain/entities/todo_item_enums.dart';
import '../cubits/tasks_cubit.dart';
import '../cubits/tasks_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bottom_sheet.dart';
import '../widgets/task_form_modal.dart';

class TasksScreen extends StatefulWidget {
  final String? initialTodoListId;
  final String? todoListName;

  const TasksScreen({
    super.key,
    this.initialTodoListId,
    this.todoListName,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialFilter = TodoItemFilterDto(
        todoListId: widget.initialTodoListId,
      );
      context.read<TasksCubit>().loadTasks(customFilter: initialFilter);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TasksCubit>().loadNextPage();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<TasksCubit>().updateSearch(query.trim());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _openCreateModal() async {
    final created = await TaskFormModal.show(
      context,
      preselectedTodoListId: widget.initialTodoListId,
    );
    if (created != null && mounted) {
      context.read<TasksCubit>().taskUpdatedOrCreated(created);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${created.title}" görevi oluşturuldu.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  Future<void> _openEditModal(TodoItemResponseDto task) async {
    final updated = await TaskFormModal.show(context, task: task);
    if (updated != null && mounted) {
      context.read<TasksCubit>().taskUpdatedOrCreated(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${updated.title}" görevi güncellendi.'),
          backgroundColor: Colors.blue.shade700,
        ),
      );
    }
  }

  Future<void> _openFilterSheet(TodoItemFilterDto currentFilter) async {
    final updatedFilter = await TaskFilterBottomSheet.show(
      context,
      currentFilter: currentFilter,
    );
    if (updatedFilter != null && mounted) {
      context.read<TasksCubit>().updateFilter(updatedFilter);
    }
  }

  Future<void> _confirmDelete(TodoItemResponseDto task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text(
          '"${task.title}" görevi çöp kutusuna taşınacak. Emin misiniz?',
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
      final success = await context.read<TasksCubit>().deleteTask(task.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görev silindi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  bool _isFilterActive(TodoItemFilterDto filter) {
    return filter.filterType != 0 ||
        filter.status != null ||
        filter.priority != null ||
        (filter.todoListId != null &&
            filter.todoListId != widget.initialTodoListId) ||
        filter.sortBy != 'createdAt' ||
        filter.sortOrder != 'desc';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.todoListName ?? 'Tüm Görevler';

    return BlocConsumer<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.status != TasksStatus.loading &&
            state.status != TasksStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final hasActiveFilter = _isFilterActive(state.filter);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filtrele & Sırala',
                    onPressed: () => _openFilterSheet(state.filter),
                  ),
                  if (hasActiveFilter)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateModal,
            icon: const Icon(Icons.add),
            label: const Text('Yeni Görev'),
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Görevlerde ara...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<TasksCubit>().updateSearch(null);
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              // Active filter chips
              if (hasActiveFilter)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      if (state.filter.status != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(
                              state.filter.status == 0 ? 'Açık' : 'Tamamlandı',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () {
                              context.read<TasksCubit>().updateFilter(
                                    state.filter.copyWith(clearStatus: true),
                                  );
                            },
                          ),
                        ),
                      if (state.filter.priority != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(
                              'Öncelik: ${TaskPriority.fromServer(state.filter.priority).displayName}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () {
                              context.read<TasksCubit>().updateFilter(
                                    state.filter.copyWith(clearPriority: true),
                                  );
                            },
                          ),
                        ),
                      if (state.filter.filterType != 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(
                              TaskFilterType.fromInt(state.filter.filterType)
                                  .displayName,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: () {
                              context.read<TasksCubit>().updateFilter(
                                    state.filter.copyWith(filterType: 0),
                                  );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

              // Main List Content
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.status == TasksStatus.loading &&
                        state.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == TasksStatus.error &&
                        state.items.isEmpty) {
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
                                state.errorMessage ??
                                    'Görevler yüklenemedi.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<TasksCubit>().loadTasks(),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state.items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<TasksCubit>().refreshTasks(),
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.task_alt,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Henüz görev bulunamadı',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '+ butonuyla ilk görevinizi oluşturun.',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<TasksCubit>().refreshTasks(),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount:
                            state.items.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }

                          final task = state.items[index];
                          return TaskCard(
                            task: task,
                            onTap: () async {
                              final tasksCubit = context.read<TasksCubit>();
                              final result = await context.pushNamed(
                                RouteNames.taskDetail,
                                pathParameters: {'id': task.id},
                              );
                              if (!mounted) return;
                              if (result is TodoItemResponseDto) {
                                tasksCubit.taskUpdatedOrCreated(result);
                              } else if (result == 'deleted') {
                                tasksCubit.refreshTasks();
                              }
                            },
                            onToggleComplete: () {
                              context
                                  .read<TasksCubit>()
                                  .toggleComplete(task.id);
                            },
                            onEdit: () => _openEditModal(task),
                            onDelete: () => _confirmDelete(task),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
