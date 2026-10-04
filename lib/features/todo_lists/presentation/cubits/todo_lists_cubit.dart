import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/todo_list_response_dto.dart';
import '../../domain/repositories/todo_lists_repository.dart';
import 'todo_lists_state.dart';

class TodoListsCubit extends Cubit<TodoListsState> {
  final TodoListsRepository repository;

  TodoListsCubit({required this.repository})
      : super(const TodoListsState());

  @override
  void emit(TodoListsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadLists() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final lists = await repository.getTodoLists();
      emit(state.copyWith(isLoading: false, lists: lists));
    } on Failure catch (f) {
      emit(state.copyWith(isLoading: false, errorMessage: f.message));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Görev listeleri yüklenirken bir hata oluştu.',
      ));
    }
  }

  Future<bool> deleteList(String id) async {
    emit(state.copyWith(isDeleting: true, clearError: true, clearSuccess: true));
    try {
      await repository.deleteTodoList(id);
      final updatedLists = state.lists.where((list) => list.id != id).toList();
      emit(state.copyWith(
        isDeleting: false,
        lists: updatedLists,
        successMessage: 'Liste başarıyla silindi.',
      ));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(isDeleting: false, errorMessage: f.message));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: 'Liste silinirken bir hata oluştu.',
      ));
      return false;
    }
  }

  void addList(TodoListResponseDto list) {
    final updatedLists = [list, ...state.lists];
    emit(state.copyWith(lists: updatedLists));
  }

  void updateListInState(TodoListResponseDto updatedList) {
    final updatedLists = state.lists.map((l) {
      return l.id == updatedList.id ? updatedList : l;
    }).toList();
    emit(state.copyWith(lists: updatedLists));
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
