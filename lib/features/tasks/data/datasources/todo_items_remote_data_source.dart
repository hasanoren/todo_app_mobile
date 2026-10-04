import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/create_todo_item_request.dart';
import '../models/paginated_todo_items_response_dto.dart';
import '../models/todo_item_filter_dto.dart';
import '../models/todo_item_response_dto.dart';
import '../models/update_todo_item_request.dart';

abstract class TodoItemsRemoteDataSource {
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTodoItems(
    TodoItemFilterDto filter,
  );
  Future<TodoItemResponseDto> getTodoItemById(String id);
  Future<TodoItemResponseDto> createTodoItem(CreateTodoItemRequest request);
  Future<TodoItemResponseDto> updateTodoItem(
    String id,
    UpdateTodoItemRequest request,
  );
  Future<TodoItemResponseDto> toggleComplete(String id);
  Future<void> deleteTodoItem(String id);
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTrashItems({
    int page = 1,
    int pageSize = 20,
  });
  Future<TodoItemResponseDto> restoreTodoItem(String id);
  Future<void> permanentDeleteTodoItem(String id);
}

class TodoItemsRemoteDataSourceImpl implements TodoItemsRemoteDataSource {
  final Dio dio;

  TodoItemsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTodoItems(
    TodoItemFilterDto filter,
  ) async {
    try {
      final response = await dio.get(
        ApiConstants.todoItems,
        queryParameters: filter.toQueryParams(),
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
  Future<TodoItemResponseDto> getTodoItemById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.todoItems}/$id');
      return TodoItemResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TodoItemResponseDto> createTodoItem(
    CreateTodoItemRequest request,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.todoItems,
        data: request.toJson(),
      );
      return TodoItemResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TodoItemResponseDto> updateTodoItem(
    String id,
    UpdateTodoItemRequest request,
  ) async {
    try {
      final response = await dio.put(
        '${ApiConstants.todoItems}/$id',
        data: request.toJson(),
      );
      return TodoItemResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TodoItemResponseDto> toggleComplete(String id) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.todoItems}/$id/complete',
      );
      return TodoItemResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> deleteTodoItem(String id) async {
    try {
      await dio.delete('${ApiConstants.todoItems}/$id');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTrashItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.todoItemsTrash,
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
  Future<TodoItemResponseDto> restoreTodoItem(String id) async {
    try {
      final response = await dio.post(ApiConstants.todoItemRestore(id));
      return TodoItemResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> permanentDeleteTodoItem(String id) async {
    try {
      await dio.delete(ApiConstants.todoItemPermanent(id));
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
