import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/subtasks_repository.dart';
import '../datasources/subtasks_remote_data_source.dart';
import '../models/create_subtask_request.dart';
import '../models/subtask_response_dto.dart';

class SubtasksRepositoryImpl implements SubtasksRepository {
  final SubtasksRemoteDataSource remoteDataSource;

  SubtasksRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SubtaskResponseDto>> getSubtasks(String taskId) async {
    try {
      return await remoteDataSource.getSubtasks(taskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Alt görevler yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<SubtaskResponseDto> createSubtask(String taskId, String title) async {
    try {
      final request = CreateSubtaskRequest(title: title);
      return await remoteDataSource.createSubtask(taskId, request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Alt görev eklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<SubtaskResponseDto> toggleComplete(String subtaskId) async {
    try {
      return await remoteDataSource.toggleComplete(subtaskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Alt görev durumu değiştirilemedi.');
    }
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await remoteDataSource.deleteSubtask(subtaskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Alt görev silinemedi.');
    }
  }
}
