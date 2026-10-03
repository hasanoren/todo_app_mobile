import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import 'package:todo_app_mobile/features/tasks/data/models/paginated_todo_items_response_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_response_dto.dart';
import '../models/create_tag_request.dart';
import '../models/tag_response_dto.dart';
import '../models/tags_collection_response_dto.dart';

abstract class TagsRemoteDataSource {
  Future<List<TagResponseDto>> getSystemTags();
  Future<TagResponseDto> createTag(CreateTagRequest request);
  Future<PaginatedTodoItemsResponseDto> getTasksByTag(
    String tagId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<List<TagResponseDto>> getTaskTags(String taskId);
  Future<void> attachTagToTask(String taskId, String tagId);
  Future<void> detachTagFromTask(String taskId, String tagId);
}

class TagsRemoteDataSourceImpl implements TagsRemoteDataSource {
  final Dio dio;

  TagsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TagResponseDto>> getSystemTags() async {
    try {
      final response = await dio.get(ApiConstants.tags);
      final collection = TagsCollectionResponseDto.fromJson(response.data);
      return collection.items;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TagResponseDto> createTag(CreateTagRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.tags,
        data: request.toJson(),
      );
      return TagResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<PaginatedTodoItemsResponseDto> getTasksByTag(
    String tagId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.tagTasks(tagId),
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final json = response.data as Map<String, dynamic>;
      return PaginatedResponseDto.fromJson(
        json,
        (itemJson) =>
            TodoItemResponseDto.fromJson(itemJson as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<List<TagResponseDto>> getTaskTags(String taskId) async {
    try {
      final response = await dio.get(ApiConstants.taskTags(taskId));
      final collection = TagsCollectionResponseDto.fromJson(response.data);
      return collection.items;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> attachTagToTask(String taskId, String tagId) async {
    try {
      await dio.post(ApiConstants.taskTag(taskId, tagId));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> detachTagFromTask(String taskId, String tagId) async {
    try {
      await dio.delete(ApiConstants.taskTag(taskId, tagId));
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
