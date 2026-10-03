import 'package:equatable/equatable.dart';

import '../../data/models/todo_item_response_dto.dart';
import '../../domain/entities/todo_item_enums.dart';

enum TaskFormStatus { initial, submitting, success, error }

class TaskFormState extends Equatable {
  final TaskFormStatus status;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final String? todoListId;
  final bool isEditing;
  final String? taskId;
  final String? errorMessage;
  final TodoItemResponseDto? resultTask;

  const TaskFormState({
    this.status = TaskFormStatus.initial,
    this.title = '',
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.todoListId,
    this.isEditing = false,
    this.taskId,
    this.errorMessage,
    this.resultTask,
  });

  bool get isValid => title.trim().isNotEmpty && title.trim().length <= 200;

  TaskFormState copyWith({
    TaskFormStatus? status,
    String? title,
    String? description,
    bool clearDescription = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskPriority? priority,
    String? todoListId,
    bool clearTodoListId = false,
    bool? isEditing,
    String? taskId,
    String? errorMessage,
    TodoItemResponseDto? resultTask,
  }) {
    return TaskFormState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      todoListId: clearTodoListId ? null : (todoListId ?? this.todoListId),
      isEditing: isEditing ?? this.isEditing,
      taskId: taskId ?? this.taskId,
      errorMessage: errorMessage,
      resultTask: resultTask ?? this.resultTask,
    );
  }

  @override
  List<Object?> get props => [
    status,
    title,
    description,
    dueDate,
    priority,
    todoListId,
    isEditing,
    taskId,
    errorMessage,
    resultTask,
  ];
}
