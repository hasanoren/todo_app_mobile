import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../data/models/todo_list_response_dto.dart';
import '../../domain/repositories/todo_lists_repository.dart';
import '../cubits/todo_lists_cubit.dart';
import '../cubits/todo_lists_state.dart';
import '../widgets/todo_list_card.dart';
import '../widgets/todo_list_form_modal.dart';

class TodoListsScreen extends StatefulWidget {
  final TodoListsRepository repository;

  const TodoListsScreen({super.key, required this.repository});

  @override
  State<TodoListsScreen> createState() => _TodoListsScreenState();
}

class _TodoListsScreenState extends State<TodoListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoListsCubit>().loadLists();
    });
  }

  void _openCreateModal() async {
    final result = await TodoListFormModal.show(
      context,
      repository: widget.repository,
    );

    if (result != null && mounted) {
      context.read<TodoListsCubit>().addList(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${result.name}" listesi oluşturuldu.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  void _openEditModal(TodoListResponseDto list) async {
    final result = await TodoListFormModal.show(
      context,
      initialList: list,
      repository: widget.repository,
    );

    if (result != null && mounted) {
      context.read<TodoListsCubit>().updateListInState(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${result.name}" listesi güncellendi.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, TodoListResponseDto list) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Listeyi Sil'),
          content: Text(
            '"${list.name}" listesini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<TodoListsCubit>().deleteList(list.id);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Listeleri'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateModal,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Liste'),
      ),
      body: BlocConsumer<TodoListsCubit, TodoListsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
            context.read<TodoListsCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
            context.read<TodoListsCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.lists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.lists.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<TodoListsCubit>().loadLists(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.playlist_add,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz bir görev listeniz yok',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Görevlerinizi gruplamak için ilk listenizi ekleyin.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _openCreateModal,
                          icon: const Icon(Icons.add),
                          label: const Text('İlk Listenizi Ekleyin'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<TodoListsCubit>().loadLists(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.lists.length,
              itemBuilder: (context, index) {
                final list = state.lists[index];
                return TodoListCard(
                  list: list,
                  onTap: () {
                    context.push(
                      '${RouteNames.tasks}?todoListId=${list.id}&todoListName=${Uri.encodeComponent(list.name)}',
                    );
                  },
                  onEdit: () => _openEditModal(list),
                  onDelete: () => _showDeleteConfirmation(context, list),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
