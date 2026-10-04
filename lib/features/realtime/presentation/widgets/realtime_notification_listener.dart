import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/realtime_event.dart';
import '../cubits/realtime_cubit.dart';
import '../cubits/realtime_state.dart';
import '../../../ownership_transfer/presentation/cubits/pending_transfers_cubit.dart';
import '../../../tasks/presentation/cubits/tasks_cubit.dart';

class RealtimeNotificationListener extends StatelessWidget {
  final Widget child;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  const RealtimeNotificationListener({
    super.key,
    required this.child,
    this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<RealtimeCubit, RealtimeState>(
      listenWhen: (previous, current) =>
          current.lastEvent != null &&
          current.lastEventTime != previous.lastEventTime,
      listener: (context, state) {
        final event = state.lastEvent;
        if (event == null) return;

        _handleEvent(context, event);
      },
      child: child,
    );
  }

  void _handleEvent(BuildContext context, RealtimeEvent event) {
    if (event is ReceiveNotificationEvent) {
      _showSnackBar(
        context,
        icon: Icons.notifications_active_outlined,
        color: Colors.blueGrey.shade900,
        title: event.title.isNotEmpty ? event.title : 'Bildirim',
        message: event.message,
      );
    } else if (event is TaskSharedEvent) {
      _showSnackBar(
        context,
        icon: Icons.person_add_alt_1_outlined,
        color: Colors.indigo.shade800,
        title: 'Yeni Görev Paylaşıldı',
        message:
            '"${event.taskTitle.isNotEmpty ? event.taskTitle : 'Yeni görev'}" sizinle paylaşıldı.',
      );
      _triggerTasksRefresh(context);
    } else if (event is TaskUpdatedEvent) {
      _triggerTasksRefresh(context);
    } else if (event is TransferRequestedEvent) {
      _showSnackBar(
        context,
        icon: Icons.swap_horiz_rounded,
        color: Colors.deepPurple.shade800,
        title: 'Sahiplik Devir İsteği',
        message:
            '"${event.taskTitle.isNotEmpty ? event.taskTitle : 'Görev'}" için size devir isteği gönderildi.',
      );
      _triggerTransfersRefresh(context);
    }
  }

  void _triggerTasksRefresh(BuildContext context) {
    try {
      context.read<TasksCubit>().loadTasks();
    } catch (_) {
      // Cubit might not be present in current context tree
    }
  }

  void _triggerTransfersRefresh(BuildContext context) {
    try {
      context.read<PendingTransfersCubit>().loadPendingTransfers();
    } catch (_) {
      // Cubit might not be present in current context tree
    }
  }

  void _showSnackBar(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    final messenger = scaffoldMessengerKey?.currentState ??
        ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('[Realtime] Cannot display snackbar: No ScaffoldMessenger');
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

