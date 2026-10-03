import 'package:equatable/equatable.dart';

import '../../data/models/todo_item_response_dto.dart';

enum TaskDetailStatus { initial, loading, success, error, deleted }

class TaskDetailState extends Equatable {
  final TaskDetailStatus status;
  final TodoItemResponseDto? task;
  final bool isToggling;
  final String? errorMessage;

  const TaskDetailState({
    this.status = TaskDetailStatus.initial,
    this.task,
    this.isToggling = false,
    this.errorMessage,
  });

  TaskDetailState copyWith({
    TaskDetailStatus? status,
    TodoItemResponseDto? task,
    bool? isToggling,
    String? errorMessage,
  }) {
    return TaskDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      isToggling: isToggling ?? this.isToggling,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, task, isToggling, errorMessage];
}

