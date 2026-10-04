import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure.dart';
import 'package:todo_app_mobile/features/tasks/domain/repositories/todo_items_repository.dart';
import '../../domain/repositories/tags_repository.dart';
import 'tagged_tasks_state.dart';

class TaggedTasksCubit extends Cubit<TaggedTasksState> {
  final TagsRepository tagsRepository;
  final TodoItemsRepository? todoItemsRepository;
  final String tagId;

  TaggedTasksCubit({
    required this.tagsRepository,
    required this.tagId,
    this.todoItemsRepository,
  }) : super(const TaggedTasksState());

  Future<void> loadTasks({bool resetPage = true}) async {
    final pageToLoad = resetPage ? 1 : state.page;
    emit(state.copyWith(
      status: TaggedTasksStatus.loading,
      page: pageToLoad,
      clearErrorMessage: true,
    ));

    try {
      final response = await tagsRepository.getTasksByTag(
        tagId,
        page: pageToLoad,
        pageSize: 20,
      );

      emit(state.copyWith(
        status: TaggedTasksStatus.success,
        items: response.items,
        page: response.page,
        hasNextPage: response.hasNextPage,
        totalCount: response.totalCount,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        status: TaggedTasksStatus.error,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: TaggedTasksStatus.error,
        errorMessage: 'Görevler yüklenirken beklenmedik bir hata oluştu.',
      ));
    }
  }

  Future<void> refresh() async {
    try {
      final response = await tagsRepository.getTasksByTag(
        tagId,
        page: 1,
        pageSize: 20,
      );
      emit(state.copyWith(
        status: TaggedTasksStatus.success,
        items: response.items,
        page: 1,
        hasNextPage: response.hasNextPage,
        totalCount: response.totalCount,
        clearErrorMessage: true,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Yenileme sırasında bir hata oluştu.'));
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasNextPage || state.status == TaggedTasksStatus.loading) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true));

    try {
      final response = await tagsRepository.getTasksByTag(
        tagId,
        page: nextPage,
        pageSize: 20,
      );

      emit(state.copyWith(
        isLoadingMore: false,
        page: response.page,
        hasNextPage: response.hasNextPage,
        totalCount: response.totalCount,
        items: [...state.items, ...response.items],
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Daha fazla görev yüklenemedi.',
      ));
    }
  }

  Future<void> toggleComplete(String taskId) async {
    if (todoItemsRepository == null) return;
    try {
      final updated = await todoItemsRepository!.toggleComplete(taskId);
      final updatedItems = state.items.map((item) {
        if (item.id == taskId) {
          return item.copyWith(
            status: updated.status,
            completedAt: updated.completedAt,
            completedByUserId: updated.completedByUserId,
          );
        }
        return item;
      }).toList();
      emit(state.copyWith(items: updatedItems));
    } catch (_) {
      // Ignored or handled silently
    }
  }
}
