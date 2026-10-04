import 'package:equatable/equatable.dart';

import '../../../tasks/data/models/todo_item_response_dto.dart';

enum TaskSharesStatus {
  initial,
  loading,
  success,
  actionInProgress,
  leftTask,
  error,
}

class TaskSharesState extends Equatable {
  final TaskSharesStatus status;
  final List<SharedUserItemDto> shares;
  final String? errorMessage;
  final String? successMessage;

  const TaskSharesState({
    this.status = TaskSharesStatus.initial,
    this.shares = const [],
    this.errorMessage,
    this.successMessage,
  });

  TaskSharesState copyWith({
    TaskSharesStatus? status,
    List<SharedUserItemDto>? shares,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return TaskSharesState(
      status: status ?? this.status,
      shares: shares ?? this.shares,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, shares, errorMessage, successMessage];
}

