import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/task_activities_repository.dart';
import 'task_activities_state.dart';

class TaskActivitiesCubit extends Cubit<TaskActivitiesState> {
  final TaskActivitiesRepository repository;

  TaskActivitiesCubit({required this.repository})
      : super(const TaskActivitiesState());

  @override
  void emit(TaskActivitiesState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadActivities(String taskId) async {
    emit(
      state.copyWith(
        status: TaskActivitiesStatus.loading,
        clearError: true,
      ),
    );
    try {
      final activities = await repository.getActivities(taskId);
      // Sort newest first
      final sortedActivities = [...activities]..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      emit(
        state.copyWith(
          status: TaskActivitiesStatus.success,
          activities: sortedActivities,
          clearError: true,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TaskActivitiesStatus.error,
          errorMessage: f.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskActivitiesStatus.error,
          errorMessage: 'Aktivite geçmişi yüklenemedi.',
        ),
      );
    }
  }

  Future<void> refreshActivities(String taskId) async {
    try {
      final activities = await repository.getActivities(taskId);
      final sortedActivities = [...activities]..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      emit(
        state.copyWith(
          status: TaskActivitiesStatus.success,
          activities: sortedActivities,
          clearError: true,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: TaskActivitiesStatus.error,
          errorMessage: f.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TaskActivitiesStatus.error,
          errorMessage: 'Aktivite geçmişi yenilenemedi.',
        ),
      );
    }
  }
}
