import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../tasks/data/models/todo_item_response_dto.dart';
import '../models/share_task_request.dart';
import '../models/share_task_response_dto.dart';
import '../models/shares_collection_response_dto.dart';

abstract class TaskSharesRemoteDataSource {
  Future<List<SharedUserItemDto>> getTaskShares(String taskId);
  Future<ShareTaskResponseDto> shareTask(String taskId, ShareTaskRequest request);
  Future<void> removeCollaborator(String taskId, String userId);
  Future<void> leaveSharedTask(String taskId);
}

class TaskSharesRemoteDataSourceImpl implements TaskSharesRemoteDataSource {
  final Dio dio;

  TaskSharesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SharedUserItemDto>> getTaskShares(String taskId) async {
    try {
      final response = await dio.get(ApiConstants.taskShares(taskId));
      final parsed = SharesCollectionResponseDto.fromJson(response.data);
      return parsed.items;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<ShareTaskResponseDto> shareTask(
    String taskId,
    ShareTaskRequest request,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.taskShares(taskId),
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return ShareTaskResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const ShareTaskResponseDto(
        message: 'Görev başarıyla paylaşıldı.',
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> removeCollaborator(String taskId, String userId) async {
    try {
      await dio.delete(ApiConstants.taskShareUser(taskId, userId));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> leaveSharedTask(String taskId) async {
    try {
      await dio.delete(ApiConstants.taskShareMe(taskId));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.response != null) {
      throw ApiException.fromJson(
        e.response!.data is Map<String, dynamic>
            ? e.response!.data as Map<String, dynamic>
            : {},
        e.response!.statusCode ?? 500,
      );
    } else {
      throw ApiException(
        statusCode: 500,
        title: 'Network Error',
        detail: e.message ?? 'Bir ağ hatası oluştu.',
      );
    }
  }
}

