import 'package:equatable/equatable.dart';

import '../../data/models/todo_item_filter_dto.dart';
import '../../data/models/todo_item_response_dto.dart';

enum TasksStatus { initial, loading, success, error }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<TodoItemResponseDto> items;
  final TodoItemFilterDto filter;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? errorMessage;

  const TasksState({
    this.status = TasksStatus.initial,
    this.items = const [],
    this.filter = const TodoItemFilterDto(),
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  TasksState copyWith({
    TasksStatus? status,
    List<TodoItemResponseDto>? items,
    TodoItemFilterDto? filter,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        filter,
        hasNextPage,
        isLoadingMore,
        errorMessage,
      ];
}

