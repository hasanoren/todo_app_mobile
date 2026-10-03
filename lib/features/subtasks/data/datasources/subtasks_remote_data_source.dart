import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/create_subtask_request.dart';
import '../models/subtask_response_dto.dart';
import '../models/subtasks_collection_response_dto.dart';

abstract class SubtasksRemoteDataSource {
  Future<List<SubtaskResponseDto>> getSubtasks(String taskId);
  Future<SubtaskResponseDto> createSubtask(
    String taskId,
    CreateSubtaskRequest request,
  );
  Future<SubtaskResponseDto> toggleComplete(String subtaskId);
  Future<void> deleteSubtask(String subtaskId);
}

class SubtasksRemoteDataSourceImpl implements SubtasksRemoteDataSource {
  final Dio dio;

  SubtasksRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SubtaskResponseDto>> getSubtasks(String taskId) async {
    try {
      final response = await dio.get(ApiConstants.taskSubtasks(taskId));
      final collection = SubtasksCollectionResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return collection.items;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<SubtaskResponseDto> createSubtask(
    String taskId,
    CreateSubtaskRequest request,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.taskSubtasks(taskId),
        data: request.toJson(),
      );
      return SubtaskResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<SubtaskResponseDto> toggleComplete(String subtaskId) async {
    try {
      final response = await dio.patch(
        ApiConstants.subtaskComplete(subtaskId),
      );
      return SubtaskResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await dio.delete(ApiConstants.subtask(subtaskId));
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
