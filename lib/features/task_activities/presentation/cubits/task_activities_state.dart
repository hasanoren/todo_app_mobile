import 'package:equatable/equatable.dart';

import '../../data/models/todo_item_activity_response_dto.dart';

enum TaskActivitiesStatus {
  initial,
  loading,
  success,
  error,
}

class TaskActivitiesState extends Equatable {
  final TaskActivitiesStatus status;
  final List<TodoItemActivityResponseDto> activities;
  final String? errorMessage;

  const TaskActivitiesState({
    this.status = TaskActivitiesStatus.initial,
    this.activities = const [],
    this.errorMessage,
  });

  TaskActivitiesState copyWith({
    TaskActivitiesStatus? status,
    List<TodoItemActivityResponseDto>? activities,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskActivitiesState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, activities, errorMessage];
}
