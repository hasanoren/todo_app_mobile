import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../../domain/repositories/todo_items_repository.dart';
import 'task_detail_state.dart';

class TaskDetailCubit extends Cubit<TaskDetailState> {
  final TodoItemsRepository repository;

  TaskDetailCubit({required this.repository}) : super(const TaskDetailState());

  @override
  void emit(TaskDetailState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadTask(String id) async {
    emit(state.copyWith(status: TaskDetailStatus.loading, errorMessage: null));

    try {
      final task = await repository.getTodoItemById(id);
      emit(state.copyWith(status: TaskDetailStatus.success, task: task));
    } on Failure catch (f) {
      emit(
        state.copyWith(status: TaskDetailStatus.error, errorMessage: f.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskDetailStatus.error,
          errorMessage: 'Görev detayları alınamadı.',
        ),
      );
    }
  }

  Future<void> toggleComplete() async {
    if (state.task == null || state.isToggling) return;

    final currentTask = state.task!;
    emit(state.copyWith(isToggling: true));

    try {
      final updated = await repository.toggleComplete(currentTask.id);
      emit(state.copyWith(task: updated, isToggling: false));
    } on Failure catch (f) {
      emit(state.copyWith(isToggling: false, errorMessage: f.message));
    } catch (_) {
      emit(
        state.copyWith(
          isToggling: false,
          errorMessage: 'Görev durumu güncellenemedi.',
        ),
      );
    }
  }

  Future<bool> deleteTask() async {
    if (state.task == null) return false;

    try {
      await repository.deleteTodoItem(state.task!.id);
      emit(state.copyWith(status: TaskDetailStatus.deleted));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
      return false;
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Görev silinemedi.'));
      return false;
    }
  }

  void onTaskUpdated(TodoItemResponseDto updated) {
    emit(state.copyWith(task: updated));
  }
}
