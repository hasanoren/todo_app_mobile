import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_app_mobile/features/tasks/domain/repositories/todo_items_repository.dart';
import 'package:todo_app_mobile/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:todo_app_mobile/features/tasks/presentation/widgets/task_card.dart';
import '../../domain/repositories/tags_repository.dart';
import '../cubits/tagged_tasks_cubit.dart';
import '../cubits/tagged_tasks_state.dart';
import '../../data/models/tag_response_dto.dart';

class TaggedTasksScreen extends StatefulWidget {
  final TagResponseDto tag;

  const TaggedTasksScreen({super.key, required this.tag});

  @override
  State<TaggedTasksScreen> createState() => _TaggedTasksScreenState();
}

class _TaggedTasksScreenState extends State<TaggedTasksScreen> {
  final _scrollController = ScrollController();
  late TaggedTasksCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TaggedTasksCubit(
      tagsRepository: context.read<TagsRepository>(),
      todoItemsRepository: context.read<TodoItemsRepository>(),
      tagId: widget.tag.id,
    )..loadTasks();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, size: 20, color: Colors.indigo),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.tag.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<TaggedTasksCubit, TaggedTasksState>(
              builder: (context, state) {
                if (state.status == TaggedTasksStatus.success) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.indigo.shade200,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${state.totalCount} Görev',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<TaggedTasksCubit, TaggedTasksState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.status != TaggedTasksStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == TaggedTasksStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == TaggedTasksStatus.error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade400, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Görevler yüklenemedi.',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _cubit.loadTasks(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (state.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => _cubit.refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label_off_outlined,
                                size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Bu etikete sahip görev bulunmuyor',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
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
              onRefresh: () => _cubit.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final task = state.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TaskCard(
                      task: task,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: task.id),
                          ),
                        );
                        _cubit.refresh();
                      },
                      onToggleComplete: () => _cubit.toggleComplete(task.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
