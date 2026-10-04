import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../tasks/data/models/todo_item_response_dto.dart';
import '../../domain/repositories/task_shares_repository.dart';
import '../datasources/task_shares_remote_data_source.dart';
import '../models/share_task_request.dart';
import '../models/share_task_response_dto.dart';

class TaskSharesRepositoryImpl implements TaskSharesRepository {
  final TaskSharesRemoteDataSource remoteDataSource;

  TaskSharesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SharedUserItemDto>> getTaskShares(String taskId) async {
    try {
      return await remoteDataSource.getTaskShares(taskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Paylaşılan kullanıcılar yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<ShareTaskResponseDto> shareTask(
    String taskId,
    ShareTaskRequest request,
  ) async {
    try {
      return await remoteDataSource.shareTask(taskId, request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Görev paylaşılırken bir hata oluştu.',
      );
    }
  }

  @override
  Future<void> removeCollaborator(String taskId, String userId) async {
    try {
      await remoteDataSource.removeCollaborator(taskId, userId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Kullanıcı görevden çıkarılırken bir hata oluştu.',
      );
    }
  }

  @override
  Future<void> leaveSharedTask(String taskId) async {
    try {
      await remoteDataSource.leaveSharedTask(taskId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Görevden ayrılırken bir hata oluştu.',
      );
    }
  }
}

