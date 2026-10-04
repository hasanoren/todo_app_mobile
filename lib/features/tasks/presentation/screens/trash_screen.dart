import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/trash_cubit.dart';
import '../cubits/trash_state.dart';
import '../widgets/trash_task_card.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TrashCubit>().loadMore();
    }
  }

  Future<void> _confirmPermanentDelete(String taskId, String taskTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kalıcı Olarak Sil'),
        content: Text(
          '"$taskTitle" görevi tamamen silinecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
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
            child: const Text('Kalıcı Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TrashCubit>().permanentDeleteItem(taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çöp Kutusu'),
      ),
      body: BlocConsumer<TrashCubit, TrashState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          } else if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TrashStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TrashStatus.error && state.items.isEmpty) {
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
                      state.errorMessage ?? 'Çöp kutusu yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<TrashCubit>().loadTrash(refresh: true),
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
                  context.read<TrashCubit>().loadTrash(refresh: true),
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_sweep_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Çöp Kutusu Boş',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Silinen görevleriniz burada listelenir.',
                            style: theme.textTheme.bodySmall?.copyWith(
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
                context.read<TrashCubit>().loadTrash(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final item = state.items[index];
                return TrashTaskCard(
                  item: item,
                  onRestore: () {
                    context.read<TrashCubit>().restoreItem(item.id);
                  },
                  onPermanentDelete: () {
                    _confirmPermanentDelete(item.id, item.title);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

