import 'package:equatable/equatable.dart';

abstract class RealtimeEvent extends Equatable {
  const RealtimeEvent();

  @override
  List<Object?> get props => [];
}

class ReceiveNotificationEvent extends RealtimeEvent {
  final String title;
  final String message;

  const ReceiveNotificationEvent({
    required this.title,
    required this.message,
  });

  @override
  List<Object?> get props => [title, message];
}

class TaskSharedEvent extends RealtimeEvent {
  final String taskId;
  final String taskTitle;

  const TaskSharedEvent({
    required this.taskId,
    required this.taskTitle,
  });

  @override
  List<Object?> get props => [taskId, taskTitle];
}

class TaskUpdatedEvent extends RealtimeEvent {
  final String taskId;

  const TaskUpdatedEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class TransferRequestedEvent extends RealtimeEvent {
  final String requestId;
  final String taskTitle;

  const TransferRequestedEvent({
    required this.requestId,
    required this.taskTitle,
  });

  @override
  List<Object?> get props => [requestId, taskTitle];
}

