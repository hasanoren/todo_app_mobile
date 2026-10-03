import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/create_todo_list_request.dart';
import '../models/todo_list_response_dto.dart';
import '../models/todo_lists_collection_response_dto.dart';
import '../models/update_todo_list_request.dart';

abstract class TodoListsRemoteDataSource {
  Future<List<TodoListResponseDto>> getTodoLists();
  Future<TodoListResponseDto> getTodoListById(String id);
  Future<TodoListResponseDto> createTodoList(CreateTodoListRequest request);
  Future<TodoListResponseDto> updateTodoList(String id, UpdateTodoListRequest request);
  Future<void> deleteTodoList(String id);
}

class TodoListsRemoteDataSourceImpl implements TodoListsRemoteDataSource {
  final Dio dio;

  TodoListsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoListResponseDto>> getTodoLists() async {
    try {
      final response = await dio.get(ApiConstants.todoLists);
      final collection = TodoListsCollectionResponseDto.fromJson(response.data);
      return collection.items;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TodoListResponseDto> getTodoListById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.todoLists}/$id');
      return TodoListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TodoListResponseDto> createTodoList(CreateTodoListRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.todoLists,
        data: request.toJson(),
      );
      return TodoListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TodoListResponseDto> updateTodoList(
    String id,
    UpdateTodoListRequest request,
  ) async {
    try {
      final response = await dio.put(
        '${ApiConstants.todoLists}/$id',
        data: request.toJson(),
      );
      return TodoListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> deleteTodoList(String id) async {
    try {
      await dio.delete('${ApiConstants.todoLists}/$id');
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
