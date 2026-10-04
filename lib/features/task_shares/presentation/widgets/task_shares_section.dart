import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../tasks/data/models/todo_item_response_dto.dart';
import '../../domain/repositories/task_shares_repository.dart';
import '../cubits/task_shares_cubit.dart';
import '../cubits/task_shares_state.dart';
import 'share_task_dialog.dart';

class TaskSharesSection extends StatefulWidget {
  final String taskId;
  final bool isOwner;
  final List<SharedUserItemDto>? initialShares;
  final VoidCallback? onLeaveSuccess;

  const TaskSharesSection({
    super.key,
    required this.taskId,
    required this.isOwner,
    this.initialShares,
    this.onLeaveSuccess,
  });

  @override
  State<TaskSharesSection> createState() => _TaskSharesSectionState();
}

class _TaskSharesSectionState extends State<TaskSharesSection> {
  late TaskSharesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TaskSharesCubit(
      repository: context.read<TaskSharesRepository>(),
    );

    if (widget.initialShares != null) {
      _cubit.initializeWithShares(widget.initialShares!);
    } else {
      _cubit.loadShares(widget.taskId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openShareDialog(BuildContext context) {
    ShareTaskDialog.show(
      context,
      onShare: (email) => _cubit.shareTask(widget.taskId, email),
    );
  }

  Future<void> _confirmRemoveUser(
    BuildContext context,
    SharedUserItemDto user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kullanıcıyı Çıkar'),
        content: Text(
          '${user.email} kullanıcısının bu göreve olan erişimini kaldırmak istediğinize emin misiniz?',
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
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _cubit.removeCollaborator(widget.taskId, user.userId);
    }
  }

  Future<void> _confirmLeaveTask(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevden Ayrıl'),
        content: const Text(
          'Bu paylaşılan görevden ayrılmak istediğinize emin misiniz? Görev listenizden kaldırılacaktır.',
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
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _cubit.leaveSharedTask(widget.taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<TaskSharesCubit, TaskSharesState>(
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

          if (state.status == TaskSharesStatus.leftTask) {
            widget.onLeaveSuccess?.call();
          }
        },
        builder: (context, state) {
          final shares = state.shares;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Paylaşılan Kişiler',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${shares.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.isOwner)
                    TextButton.icon(
                      onPressed: () => _openShareDialog(context),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Kişi Ekle'),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => _confirmLeaveTask(context),
                      icon: Icon(
                        Icons.exit_to_app_outlined,
                        size: 18,
                        color: Colors.red.shade700,
                      ),
                      label: Text(
                        'Paylaşımdan Ayrıl',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.status == TaskSharesStatus.loading && shares.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
              else if (shares.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.isOwner
                        ? 'Bu görev henüz kimseyle paylaşılmadı. "Kişi Ekle" ile ortak çalışabilirsiniz.'
                        : 'Bu görev sadece sizinle paylaşıldı.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shares.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final user = shares[index];
                      final dateStr =
                          DateFormat('dd.MM.yyyy').format(user.sharedAt.toLocal());
                      final initial = user.email.isNotEmpty
                          ? user.email[0].toUpperCase()
                          : '?';

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Paylaşıldı: $dateStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: widget.isOwner
                            ? IconButton(
                                icon: Icon(
                                  Icons.person_remove_outlined,
                                  size: 20,
                                  color: Colors.red.shade400,
                                ),
                                tooltip: 'Erişimi Kaldır',
                                onPressed: () =>
                                    _confirmRemoveUser(context, user),
                              )
                            : null,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

