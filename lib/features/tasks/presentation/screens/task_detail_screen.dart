import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../cubits/task_detail_cubit.dart';
import '../cubits/task_detail_state.dart';
import '../widgets/priority_badge.dart';
import '../widgets/task_form_modal.dart';
import '../../../subtasks/data/models/subtask_response_dto.dart';
import '../../../subtasks/presentation/widgets/subtasks_section.dart';
import '../../../tags/data/models/tag_response_dto.dart';
import '../../../tags/presentation/widgets/task_tags_section.dart';
import '../../../task_shares/presentation/widgets/task_shares_section.dart';
import '../../../ownership_transfer/data/models/create_transfer_request_dto.dart';
import '../../../ownership_transfer/data/models/transfer_request_response_dto.dart';
import '../../../ownership_transfer/domain/repositories/ownership_transfer_repository.dart';
import '../../../ownership_transfer/presentation/widgets/transfer_ownership_dialog.dart';
import '../../../task_activities/presentation/widgets/task_activities_section.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TransferRequestResponseDto? _activeTransfer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskDetailCubit>().loadTask(widget.taskId);
      _loadActiveTransfer();
    });
  }

  Future<void> _loadActiveTransfer() async {
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        (authState is Authenticated) ? authState.userId : null;
    final repo = context.read<OwnershipTransferRepository>();
    final active = await repo.getActiveOutgoingTransferRequest(widget.taskId);

    if (active != null && currentUserId != null) {
      if (active.fromUserId != currentUserId ||
          active.toUserId == currentUserId) {
        await repo.clearActiveOutgoingTransferRequest(widget.taskId);
        if (mounted) {
          setState(() {
            _activeTransfer = null;
          });
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _activeTransfer = active;
      });
    }
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

  Future<void> _openTransferModal(TodoItemResponseDto task) async {
    if (_activeTransfer != null) {
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bekleyen Devir İsteği'),
          content: Text(
            'Bu görev için zaten "${_activeTransfer!.toUserEmail}" adresine gönderilmiş bekleyen bir devir isteği bulunmaktadır.\n\nYeni bir istek göndermek için önce mevcut isteği iptal etmelisiniz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Kapat'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mevcut İsteği İptal Et'),
            ),
          ],
        ),
      );

      if (shouldCancel == true && mounted) {
        await _confirmCancelTransfer();
      }
      return;
    }

    await TransferOwnershipDialog.show(
      context,
      onTransfer: (email) async {
        final repo = context.read<OwnershipTransferRepository>();
        try {
          final res = await repo.createTransferRequest(
            task.id,
            CreateTransferRequestDto(newOwnerEmail: email),
          );
          if (mounted) {
            setState(() {
              _activeTransfer = res;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$email adresine devir isteği başarıyla iletildi.'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
          return true;
        } on Failure catch (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
          return false;
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Devir isteği iletilemedi.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      },
    );
  }

  Future<void> _confirmCancelTransfer() async {
    if (_activeTransfer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Devir İsteğini İptal Et'),
        content: Text(
          '"${_activeTransfer!.toUserEmail}" adresine gönderilen sahiplik devri isteğini geri çekmek istediğinize emin misiniz?\n\nGörevin tam sahipliği sizde kalmaya devam edecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('İsteği Geri Çek'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _cancelTransfer();
    }
  }

  Future<void> _cancelTransfer() async {
    if (_activeTransfer == null) return;
    final repo = context.read<OwnershipTransferRepository>();
    final requestId = _activeTransfer!.id;

    try {
      final res = await repo.cancelTransferRequest(requestId);
      if (mounted) {
        setState(() {
          _activeTransfer = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } on Failure catch (f) {
      if (mounted) {
        if (f.message.contains('zaten yanıtlanmış') ||
            f.message.contains('iptal edilmiş') ||
            f.message.contains('bulunamadı')) {
          repo.clearActiveOutgoingTransferRequest(widget.taskId);
          setState(() {
            _activeTransfer = null;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(f.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İstek iptal edilirken bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
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

        final task = state.task;
        if (task != null && _activeTransfer != null) {
          if (!task.isOwner ||
              (task.ownerId.isNotEmpty &&
                  _activeTransfer!.toUserId.isNotEmpty &&
                  task.ownerId == _activeTransfer!.toUserId)) {
            context
                .read<OwnershipTransferRepository>()
                .clearActiveOutgoingTransferRequest(task.id);
            setState(() {
              _activeTransfer = null;
            });
          }
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
                    icon: const Icon(Icons.swap_horiz_outlined),
                    tooltip: 'Sahipliği Devret',
                    onPressed: () => _openTransferModal(task),
                  ),
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

                      // Pending Transfer Banner
                      if (_activeTransfer != null &&
                          task.isOwner &&
                          (task.ownerId.isEmpty ||
                              _activeTransfer!.toUserId.isEmpty ||
                              task.ownerId != _activeTransfer!.toUserId)) ...[
                        Card(
                          color: Colors.amber.shade50,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.amber.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.hourglass_top_rounded,
                                      color: Colors.amber.shade800,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Devir İsteği Beklemede',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Bu görev "${_activeTransfer!.toUserEmail}" kullanıcısına devredilmek üzere bekliyor. Karşı taraf kabul edene kadar isteği geri çekebilirsiniz.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      side: BorderSide(
                                        color: Colors.red.shade300,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      size: 16,
                                    ),
                                    label:
                                        const Text('İsteği Geri Çek (İptal Et)'),
                                    onPressed: _confirmCancelTransfer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

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

                      // Subtasks section (FEAT-07)
                      SubtasksSection(
                        taskId: task.id,
                        isOwner: task.isOwner,
                        initialSubtasks: task.subTasks
                            .map((s) => SubtaskResponseDto(
                                  id: s.id,
                                  taskId: s.taskId,
                                  title: s.title,
                                  status: s.status,
                                  createdAt: s.createdAt,
                                  updatedAt: s.updatedAt,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      // Tags section (FEAT-08)
                      TaskTagsSection(
                        taskId: task.id,
                        isOwner: task.isOwner,
                        initialTags: task.tags
                            .map((t) => TagResponseDto(
                                  id: t.id,
                                  name: t.name,
                                  createdAt: t.createdAt,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      // Task Shares section (FEAT-09)
                      TaskSharesSection(
                        taskId: task.id,
                        isOwner: task.isOwner,
                        initialShares: task.sharedWith,
                        onLeaveSuccess: () {
                          if (mounted) {
                            Navigator.of(context).pop('deleted');
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Task Activities section (FEAT-12)
                      TaskActivitiesSection(
                        taskId: task.id,
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
