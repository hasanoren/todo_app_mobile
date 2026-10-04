import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../tasks/data/models/todo_item_response_dto.dart';
import '../../data/models/share_task_request.dart';
import '../../domain/repositories/task_shares_repository.dart';
import 'task_shares_state.dart';

class TaskSharesCubit extends Cubit<TaskSharesState> {
  final TaskSharesRepository repository;

  TaskSharesCubit({required this.repository}) : super(const TaskSharesState());

  @override
  void emit(TaskSharesState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  void initializeWithShares(List<SharedUserItemDto> initialShares) {
    emit(
      state.copyWith(
        status: TaskSharesStatus.success,
        shares: initialShares,
        clearMessages: true,
      ),
    );
  }

  Future<void> loadShares(String taskId) async {
    emit(
      state.copyWith(status: TaskSharesStatus.loading, clearMessages: true),
    );
    try {
      final shares = await repository.getTaskShares(taskId);
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          shares: shares,
          clearMessages: true,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.error,
          errorMessage: f.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.error,
          errorMessage: 'Paylaşılan kullanıcılar yüklenemedi.',
        ),
      );
    }
  }

  Future<bool> shareTask(String taskId, String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Lütfen geçerli bir e-posta adresi girin.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: TaskSharesStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      final response = await repository.shareTask(
        taskId,
        ShareTaskRequest(email: trimmedEmail),
      );
      // Refresh shares list to get accurate user info
      final updatedShares = await repository.getTaskShares(taskId);
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          shares: updatedShares,
          successMessage: response.message,
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          errorMessage: 'Görev paylaşılamadı.',
        ),
      );
      return false;
    }
  }

  Future<bool> removeCollaborator(String taskId, String userId) async {
    emit(
      state.copyWith(
        status: TaskSharesStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      await repository.removeCollaborator(taskId, userId);
      final updatedShares =
          state.shares.where((user) => user.userId != userId).toList();
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          shares: updatedShares,
          successMessage: 'Kullanıcı görevden çıkarıldı.',
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          errorMessage: 'Kullanıcı çıkarılamadı.',
        ),
      );
      return false;
    }
  }

  Future<bool> leaveSharedTask(String taskId) async {
    emit(
      state.copyWith(
        status: TaskSharesStatus.actionInProgress,
        clearMessages: true,
      ),
    );

    try {
      await repository.leaveSharedTask(taskId);
      emit(
        state.copyWith(
          status: TaskSharesStatus.leftTask,
          successMessage: 'Paylaşılan görevden ayrıldınız.',
        ),
      );
      return true;
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          errorMessage: f.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskSharesStatus.success,
          errorMessage: 'Görevden ayrılma işlemi başarısız oldu.',
        ),
      );
      return false;
    }
  }
}

