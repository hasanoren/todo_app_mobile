import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/todo_item_filter_dto.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../../domain/repositories/todo_items_repository.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TodoItemsRepository repository;

  TasksCubit({required this.repository}) : super(const TasksState());

  Future<void> loadTasks({
    bool resetPage = true,
    TodoItemFilterDto? customFilter,
  }) async {
    final activeFilter = (customFilter ?? state.filter).copyWith(
      page: resetPage ? 1 : state.filter.page,
    );

    emit(
      state.copyWith(
        status: TasksStatus.loading,
        filter: activeFilter,
        errorMessage: null,
      ),
    );

    try {
      final response = await repository.getTodoItems(activeFilter);
      emit(
        state.copyWith(
          status: TasksStatus.success,
          items: response.items,
          hasNextPage: response.hasNextPage,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: TasksStatus.error, errorMessage: f.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: 'Görevler yüklenirken beklenmedik bir hata oluştu.',
        ),
      );
    }
  }

  Future<void> refreshTasks() async {
    final refreshFilter = state.filter.copyWith(page: 1);
    try {
      final response = await repository.getTodoItems(refreshFilter);
      emit(
        state.copyWith(
          status: TasksStatus.success,
          filter: refreshFilter,
          items: response.items,
          hasNextPage: response.hasNextPage,
          errorMessage: null,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Yenileme sırasında bir hata oluştu.'));
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore ||
        !state.hasNextPage ||
        state.status == TasksStatus.loading) {
      return;
    }

    final nextPage = state.filter.page + 1;
    final nextFilter = state.filter.copyWith(page: nextPage);

    emit(
      state.copyWith(
        isLoadingMore: true,
        filter: nextFilter,
        errorMessage: null,
      ),
    );

    try {
      final response = await repository.getTodoItems(nextFilter);
      emit(
        state.copyWith(
          isLoadingMore: false,
          items: [...state.items, ...response.items],
          hasNextPage: response.hasNextPage,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: f.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Daha fazla görev yüklenemedi.',
        ),
      );
    }
  }

  Future<void> updateSearch(String? search) async {
    final newFilter = state.filter.copyWith(
      search: search,
      clearSearch: search == null || search.trim().isEmpty,
      page: 1,
    );
    await loadTasks(customFilter: newFilter);
  }

  Future<void> updateFilter(TodoItemFilterDto newFilter) async {
    await loadTasks(customFilter: newFilter.copyWith(page: 1));
  }

  Future<void> toggleComplete(String id) async {
    final index = state.items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final originalItem = state.items[index];
    final optimisticStatus = originalItem.isCompleted ? 'Open' : 'Completed';
    final updatedList = List<TodoItemResponseDto>.from(state.items);
    updatedList[index] = originalItem.copyWith(status: optimisticStatus);

    emit(state.copyWith(items: updatedList));

    try {
      final serverUpdated = await repository.toggleComplete(id);
      final finalIdx = state.items.indexWhere((item) => item.id == id);
      if (finalIdx != -1) {
        final syncedList = List<TodoItemResponseDto>.from(state.items);
        syncedList[finalIdx] = serverUpdated;
        emit(state.copyWith(items: syncedList));
      }
    } on Failure catch (f) {
      // Revert back
      final revertIdx = state.items.indexWhere((item) => item.id == id);
      if (revertIdx != -1) {
        final revertedList = List<TodoItemResponseDto>.from(state.items);
        revertedList[revertIdx] = originalItem;
        emit(state.copyWith(items: revertedList, errorMessage: f.message));
      }
    } catch (_) {
      final revertIdx = state.items.indexWhere((item) => item.id == id);
      if (revertIdx != -1) {
        final revertedList = List<TodoItemResponseDto>.from(state.items);
        revertedList[revertIdx] = originalItem;
        emit(
          state.copyWith(
            items: revertedList,
            errorMessage: 'Görev durumu güncellenemedi.',
          ),
        );
      }
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await repository.deleteTodoItem(id);
      final filteredItems = state.items.where((item) => item.id != id).toList();
      emit(state.copyWith(items: filteredItems));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
      return false;
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Görev silinemedi.'));
      return false;
    }
  }

  void taskUpdatedOrCreated(TodoItemResponseDto task) {
    final index = state.items.indexWhere((i) => i.id == task.id);
    if (index != -1) {
      final updatedList = List<TodoItemResponseDto>.from(state.items);
      updatedList[index] = task;
      emit(state.copyWith(items: updatedList));
    } else {
      emit(state.copyWith(items: [task, ...state.items]));
    }
  }
}
