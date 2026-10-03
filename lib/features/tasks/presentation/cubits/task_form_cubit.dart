import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/create_todo_item_request.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../../data/models/update_todo_item_request.dart';
import '../../domain/entities/todo_item_enums.dart';
import '../../domain/repositories/todo_items_repository.dart';
import 'task_form_state.dart';

class TaskFormCubit extends Cubit<TaskFormState> {
  final TodoItemsRepository repository;

  TaskFormCubit({required this.repository}) : super(const TaskFormState());

  void initializeForCreate({String? preselectedTodoListId}) {
    emit(TaskFormState(
      isEditing: false,
      todoListId: preselectedTodoListId,
    ));
  }

  void initializeForEdit(TodoItemResponseDto task) {
    emit(TaskFormState(
      isEditing: true,
      taskId: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.taskPriority,
      todoListId: task.todoListId,
    ));
  }

  void titleChanged(String value) {
    emit(state.copyWith(
      title: value,
      status: TaskFormStatus.initial,
      errorMessage: null,
    ));
  }

  void descriptionChanged(String? value) {
    emit(state.copyWith(
      description: value,
      clearDescription: value == null || value.trim().isEmpty,
    ));
  }

  void dueDateChanged(DateTime? value) {
    emit(state.copyWith(
      dueDate: value,
      clearDueDate: value == null,
    ));
  }

  void priorityChanged(TaskPriority value) {
    emit(state.copyWith(priority: value));
  }

  void todoListIdChanged(String? value) {
    emit(state.copyWith(
      todoListId: value,
      clearTodoListId: value == null || value.isEmpty,
    ));
  }

  Future<void> submit() async {
    final trimmedTitle = state.title.trim();
    if (trimmedTitle.isEmpty) {
      emit(state.copyWith(
        status: TaskFormStatus.error,
        errorMessage: 'Görev başlığı boş bırakılamaz.',
      ));
      return;
    }
    if (trimmedTitle.length > 200) {
      emit(state.copyWith(
        status: TaskFormStatus.error,
        errorMessage: 'Görev başlığı en fazla 200 karakter olabilir.',
      ));
      return;
    }

    emit(state.copyWith(
      status: TaskFormStatus.submitting,
      errorMessage: null,
    ));

    try {
      if (state.isEditing) {
        final request = UpdateTodoItemRequest(
          title: trimmedTitle,
          description: state.description,
          dueDate: state.dueDate,
          priority: state.priority.value,
          todoListId: state.todoListId,
        );
        final result = await repository.updateTodoItem(state.taskId!, request);
        emit(state.copyWith(
          status: TaskFormStatus.success,
          resultTask: result,
        ));
      } else {
        final request = CreateTodoItemRequest(
          title: trimmedTitle,
          description: state.description,
          dueDate: state.dueDate,
          priority: state.priority.value,
          todoListId: state.todoListId,
        );
        final result = await repository.createTodoItem(request);
        emit(state.copyWith(
          status: TaskFormStatus.success,
          resultTask: result,
        ));
      }
    } on Failure catch (f) {
      emit(state.copyWith(
        status: TaskFormStatus.error,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: TaskFormStatus.error,
        errorMessage: 'İşlem sırasında bir hata oluştu.',
      ));
    }
  }
}
