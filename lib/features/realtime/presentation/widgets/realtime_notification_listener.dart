import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/realtime_event.dart';
import '../cubits/realtime_cubit.dart';
import '../cubits/realtime_state.dart';
import '../../../ownership_transfer/presentation/cubits/pending_transfers_cubit.dart';
import '../../../tasks/presentation/cubits/tasks_cubit.dart';

class RealtimeNotificationListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  const RealtimeNotificationListener({
    super.key,
    required this.child,
    this.scaffoldMessengerKey,
  });

  @override
  State<RealtimeNotificationListener> createState() =>
      _RealtimeNotificationListenerState();
}

class _RealtimeNotificationListenerState
    extends State<RealtimeNotificationListener> {
  RealtimeEvent? _lastHandledEvent;
  DateTime? _lastHandledTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RealtimeCubit, RealtimeState>(
      listenWhen: (previous, current) =>
          current.lastEvent != null &&
          current.lastEventTime != previous.lastEventTime,
      listener: (context, state) {
        final event = state.lastEvent;
        if (event == null) return;

        // Deduplication guard: ignore duplicate identical events received within 2 seconds
        final now = DateTime.now();
        if (_lastHandledEvent == event &&
            _lastHandledTime != null &&
            now.difference(_lastHandledTime!) < const Duration(seconds: 2)) {
          debugPrint('[Realtime] Duplicate event suppressed: $event');
          return;
        }

        _lastHandledEvent = event;
        _lastHandledTime = now;
        _handleEvent(context, event);
      },
      child: widget.child,
    );
  }

  void _handleEvent(BuildContext context, RealtimeEvent event) {
    if (event is ReceiveNotificationEvent) {
      final titleLower = event.title.toLowerCase();
      final msgLower = event.message.toLowerCase();

      IconData icon = Icons.notifications_active_outlined;
      Color color = Colors.blueGrey.shade900;

      if (titleLower.contains('paylaş') || msgLower.contains('paylaş')) {
        icon = Icons.person_add_alt_1_outlined;
        color = Colors.indigo.shade800;
        _triggerTasksRefresh(context);
      } else if (titleLower.contains('devir') || msgLower.contains('devir')) {
        icon = Icons.swap_horiz_rounded;
        color = Colors.deepPurple.shade800;
        _triggerTransfersRefresh(context);
        _triggerTasksRefresh(context);
      } else if (titleLower.contains('güncelle') ||
          titleLower.contains('tamamlan') ||
          msgLower.contains('güncelle') ||
          msgLower.contains('tamamlan')) {
        icon = Icons.edit_note_outlined;
        color = Colors.teal.shade800;
        _triggerTasksRefresh(context);
      } else {
        _triggerTasksRefresh(context);
      }

      _showSnackBar(
        context,
        icon: icon,
        color: color,
        title: event.title.isNotEmpty ? event.title : 'Bildirim',
        message: event.message,
      );
    } else if (event is TaskSharedEvent) {
      if (event.taskTitle.isNotEmpty) {
        _showSnackBar(
          context,
          icon: Icons.person_add_alt_1_outlined,
          color: Colors.indigo.shade800,
          title: event.taskTitle,
          message: 'Görevi sizinle paylaşıldı.',
        );
      }
      _triggerTasksRefresh(context);
    } else if (event is TaskUpdatedEvent) {
      _triggerTasksRefresh(context);
    } else if (event is TransferRequestedEvent) {
      if (event.taskTitle.isNotEmpty) {
        _showSnackBar(
          context,
          icon: Icons.swap_horiz_rounded,
          color: Colors.deepPurple.shade800,
          title: event.taskTitle,
          message: 'Sahiplik devir isteği gönderildi.',
        );
      }
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
    final messenger = widget.scaffoldMessengerKey?.currentState ??
        ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('[Realtime] Cannot display snackbar: No ScaffoldMessenger');
      return;
    }

    messenger.removeCurrentSnackBar();
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

