import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/todo_list_response_dto.dart';
import '../../domain/repositories/todo_lists_repository.dart';
import 'todo_list_form_state.dart';

class TodoListFormCubit extends Cubit<TodoListFormState> {
  final TodoListsRepository repository;

  TodoListFormCubit({
    required this.repository,
    TodoListResponseDto? initialList,
  }) : super(TodoListFormState(
          initialList: initialList,
          name: initialList?.name ?? '',
          colorCode: initialList?.colorCode ?? '#6366F1',
        ));

  void nameChanged(String value) {
    String? error;
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      error = 'Liste adı boş bırakılamaz.';
    } else if (trimmed.length > 100) {
      error = 'Liste adı en fazla 100 karakter olabilir.';
    }
    emit(state.copyWith(
      name: value,
      nameError: error,
      clearNameError: error == null,
    ));
  }

  void colorChanged(String hexColor) {
    emit(state.copyWith(colorCode: hexColor));
  }

  Future<bool> submit() async {
    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      emit(state.copyWith(nameError: 'Liste adı boş bırakılamaz.'));
      return false;
    }
    if (trimmedName.length > 100) {
      emit(state.copyWith(nameError: 'Liste adı en fazla 100 karakter olabilir.'));
      return false;
    }

    emit(state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearNameError: true,
    ));

    try {
      if (state.isEdit) {
        final updated = await repository.updateTodoList(
          state.initialList!.id,
          trimmedName,
          state.colorCode,
        );
        emit(state.copyWith(
          isSubmitting: false,
          resultList: updated,
        ));
        return true;
      } else {
        final created = await repository.createTodoList(
          trimmedName,
          state.colorCode,
        );
        emit(state.copyWith(
          isSubmitting: false,
          resultList: created,
        ));
        return true;
      }
    } on Failure catch (f) {
      emit(state.copyWith(isSubmitting: false, errorMessage: f.message));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: state.isEdit
            ? 'Liste güncellenirken bir hata oluştu.'
            : 'Liste oluşturulurken bir hata oluştu.',
      ));
      return false;
    }
  }
}
