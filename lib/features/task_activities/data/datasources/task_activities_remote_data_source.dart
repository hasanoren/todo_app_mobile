import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/todo_item_activity_response_dto.dart';

abstract class TaskActivitiesRemoteDataSource {
  Future<List<TodoItemActivityResponseDto>> getActivities(String taskId);
}

class TaskActivitiesRemoteDataSourceImpl
    implements TaskActivitiesRemoteDataSource {
  final Dio dio;

  TaskActivitiesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoItemActivityResponseDto>> getActivities(String taskId) async {
    try {
      final response = await dio.get(ApiConstants.taskActivities(taskId));
      final data = response.data;

      if (data is List) {
        return data
            .map((e) =>
                TodoItemActivityResponseDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final list = data['items'] as List<dynamic>? ?? [];
        return list
            .map((e) =>
                TodoItemActivityResponseDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return const [];
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
