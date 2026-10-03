import 'package:equatable/equatable.dart';

import '../../data/models/todo_list_response_dto.dart';

class TodoListFormState extends Equatable {
  final TodoListResponseDto? initialList;
  final String name;
  final String colorCode;
  final String? nameError;
  final bool isSubmitting;
  final TodoListResponseDto? resultList;
  final String? errorMessage;

  const TodoListFormState({
    this.initialList,
    this.name = '',
    this.colorCode = '#6366F1',
    this.nameError,
    this.isSubmitting = false,
    this.resultList,
    this.errorMessage,
  });

  bool get isEdit => initialList != null;

  TodoListFormState copyWith({
    TodoListResponseDto? initialList,
    String? name,
    String? colorCode,
    String? nameError,
    bool? isSubmitting,
    TodoListResponseDto? resultList,
    String? errorMessage,
    bool clearNameError = false,
    bool clearError = false,
  }) {
    return TodoListFormState(
      initialList: initialList ?? this.initialList,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resultList: resultList ?? this.resultList,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        initialList,
        name,
        colorCode,
        nameError,
        isSubmitting,
        resultList,
        errorMessage,
      ];
}

