import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/todo_items_repository.dart';
import 'trash_state.dart';

class TrashCubit extends Cubit<TrashState> {
  final TodoItemsRepository repository;

  TrashCubit({required this.repository}) : super(const TrashState());

  @override
  void emit(TrashState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadTrash({bool refresh = false}) async {
    if (state.status == TrashStatus.loading && !refresh) return;

    emit(
      state.copyWith(
        status: TrashStatus.loading,
        clearMessages: true,
      ),
    );

    try {
      final response = await repository.getTrashItems(page: 1, pageSize: 20);
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          items: response.items,
          page: response.page,
          totalPages: response.totalPages,
          totalCount: response.totalCount,
          hasMore: response.page < response.totalPages,
          clearMessages: true,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TrashStatus.error,
          errorMessage: f.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TrashStatus.error,
          errorMessage: 'Çöp kutusu yüklenirken bir hata oluştu.',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status == TrashStatus.loading) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearMessages: true));

    try {
      final nextPage = state.page + 1;
      final response =
          await repository.getTrashItems(page: nextPage, pageSize: 20);
      final combined = [...state.items, ...response.items];
      emit(
        state.copyWith(
          items: combined,
          page: response.page,
          totalPages: response.totalPages,
          totalCount: response.totalCount,
          hasMore: response.page < response.totalPages,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: f.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Daha fazla görev yüklenemedi.',
        ),
      );
    }
  }

  Future<bool> restoreItem(String id) async {
    emit(
      state.copyWith(
        status: TrashStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      final restored = await repository.restoreTodoItem(id);
      final updatedList = state.items.where((item) => item.id != id).toList();
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          items: updatedList,
          totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
          successMessage: '"${restored.title}" görevi geri yüklendi.',
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          errorMessage: 'Görev geri yüklenemedi.',
        ),
      );
      return false;
    }
  }

  Future<bool> permanentDeleteItem(String id) async {
    emit(
      state.copyWith(
        status: TrashStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      await repository.permanentDeleteTodoItem(id);
      final updatedList = state.items.where((item) => item.id != id).toList();
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          items: updatedList,
          totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
          successMessage: 'Görev kalıcı olarak silindi.',
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TrashStatus.loaded,
          errorMessage: 'Görev kalıcı olarak silinemedi.',
        ),
      );
      return false;
    }
  }
}

