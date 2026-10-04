import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/subtask_response_dto.dart';
import '../../domain/repositories/subtasks_repository.dart';
import 'subtasks_state.dart';

class SubtasksCubit extends Cubit<SubtasksState> {
  final SubtasksRepository repository;

  SubtasksCubit({required this.repository}) : super(const SubtasksState());

  void setInitialItems(List<SubtaskResponseDto> initialItems) {
    emit(state.copyWith(status: SubtasksStatus.success, items: initialItems));
  }

  Future<void> loadSubtasks(String taskId) async {
    emit(state.copyWith(status: SubtasksStatus.loading, errorMessage: null));

    try {
      final items = await repository.getSubtasks(taskId);
      emit(state.copyWith(status: SubtasksStatus.success, items: items));
    } on Failure catch (f) {
      emit(
        state.copyWith(status: SubtasksStatus.error, errorMessage: f.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SubtasksStatus.error,
          errorMessage: 'Alt görevler yüklenemedi.',
        ),
      );
    }
  }

  Future<bool> addSubtask(String taskId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return false;

    emit(state.copyWith(isAdding: true, errorMessage: null));

    try {
      final created = await repository.createSubtask(taskId, trimmed);
      emit(state.copyWith(isAdding: false, items: [...state.items, created]));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(isAdding: false, errorMessage: f.message));
      return false;
    } catch (_) {
      emit(
        state.copyWith(isAdding: false, errorMessage: 'Alt görev eklenemedi.'),
      );
      return false;
    }
  }

  Future<void> toggleComplete(String subtaskId) async {
    final index = state.items.indexWhere((s) => s.id == subtaskId);
    if (index == -1) return;

    final original = state.items[index];
    final optimisticStatus = original.isCompleted ? 'Open' : 'Completed';
    final updatedList = List<SubtaskResponseDto>.from(state.items);
    updatedList[index] = original.copyWith(status: optimisticStatus);

    emit(state.copyWith(items: updatedList, togglingId: subtaskId));

    try {
      final serverUpdated = await repository.toggleComplete(subtaskId);
      final finalIdx = state.items.indexWhere((s) => s.id == subtaskId);
      if (finalIdx != -1) {
        final syncedList = List<SubtaskResponseDto>.from(state.items);
        syncedList[finalIdx] = serverUpdated;
        emit(state.copyWith(items: syncedList, clearTogglingId: true));
      }
    } on Failure catch (f) {
      // Revert on failure
      final revertIdx = state.items.indexWhere((s) => s.id == subtaskId);
      if (revertIdx != -1) {
        final revertedList = List<SubtaskResponseDto>.from(state.items);
        revertedList[revertIdx] = original;
        emit(
          state.copyWith(
            items: revertedList,
            clearTogglingId: true,
            errorMessage: f.message,
          ),
        );
      }
    } catch (_) {
      final revertIdx = state.items.indexWhere((s) => s.id == subtaskId);
      if (revertIdx != -1) {
        final revertedList = List<SubtaskResponseDto>.from(state.items);
        revertedList[revertIdx] = original;
        emit(
          state.copyWith(
            items: revertedList,
            clearTogglingId: true,
            errorMessage: 'Alt görev güncellenemedi.',
          ),
        );
      }
    }
  }

  Future<bool> deleteSubtask(String subtaskId) async {
    try {
      await repository.deleteSubtask(subtaskId);
      final remaining = state.items.where((s) => s.id != subtaskId).toList();
      emit(state.copyWith(items: remaining));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
      return false;
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Alt görev silinemedi.'));
      return false;
    }
  }
}
