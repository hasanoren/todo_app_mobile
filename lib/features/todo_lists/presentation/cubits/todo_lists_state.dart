import 'package:equatable/equatable.dart';

import '../../data/models/todo_list_response_dto.dart';

class TodoListsState extends Equatable {
  final bool isLoading;
  final bool isDeleting;
  final List<TodoListResponseDto> lists;
  final String? errorMessage;
  final String? successMessage;

  const TodoListsState({
    this.isLoading = false,
    this.isDeleting = false,
    this.lists = const [],
    this.errorMessage,
    this.successMessage,
  });

  TodoListsState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<TodoListResponseDto>? lists,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TodoListsState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      lists: lists ?? this.lists,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isDeleting,
    lists,
    errorMessage,
    successMessage,
  ];
}
