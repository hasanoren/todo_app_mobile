import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/task_activities_repository.dart';
import '../datasources/task_activities_remote_data_source.dart';
import '../models/todo_item_activity_response_dto.dart';

class TaskActivitiesRepositoryImpl implements TaskActivitiesRepository {
  final TaskActivitiesRemoteDataSource remoteDataSource;

  TaskActivitiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TodoItemActivityResponseDto>> getActivities(String taskId) async {
    try {
      return await remoteDataSource.getActivities(taskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Aktivite geçmişi yüklenirken bir hata oluştu.',
      );
    }
  }
}
