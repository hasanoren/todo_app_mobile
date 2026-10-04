import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/todo_items_repository.dart';
import '../datasources/todo_items_remote_data_source.dart';
import '../models/create_todo_item_request.dart';
import '../models/paginated_todo_items_response_dto.dart';
import '../models/todo_item_filter_dto.dart';
import '../models/todo_item_response_dto.dart';
import '../models/update_todo_item_request.dart';

class TodoItemsRepositoryImpl implements TodoItemsRepository {
  final TodoItemsRemoteDataSource remoteDataSource;

  TodoItemsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTodoItems(
    TodoItemFilterDto filter,
  ) async {
    try {
      return await remoteDataSource.getTodoItems(filter);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Görevler yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TodoItemResponseDto> getTodoItemById(String id) async {
    try {
      return await remoteDataSource.getTodoItemById(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev detayları alınamadı.');
    }
  }

  @override
  Future<TodoItemResponseDto> createTodoItem(
    CreateTodoItemRequest request,
  ) async {
    try {
      return await remoteDataSource.createTodoItem(request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev oluşturulamadı.');
    }
  }

  @override
  Future<TodoItemResponseDto> updateTodoItem(
    String id,
    UpdateTodoItemRequest request,
  ) async {
    try {
      return await remoteDataSource.updateTodoItem(id, request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev güncellenemedi.');
    }
  }

  @override
  Future<TodoItemResponseDto> toggleComplete(String id) async {
    try {
      return await remoteDataSource.toggleComplete(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev durumu güncellenemedi.');
    }
  }

  @override
  Future<void> deleteTodoItem(String id) async {
    try {
      await remoteDataSource.deleteTodoItem(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev silinemedi.');
    }
  }

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTrashItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await remoteDataSource.getTrashItems(
        page: page,
        pageSize: pageSize,
      );
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Çöp kutusundaki görevler yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TodoItemResponseDto> restoreTodoItem(String id) async {
    try {
      return await remoteDataSource.restoreTodoItem(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev geri yüklenemedi.');
    }
  }

  @override
  Future<void> permanentDeleteTodoItem(String id) async {
    try {
      await remoteDataSource.permanentDeleteTodoItem(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Görev kalıcı olarak silinemedi.');
    }
  }
}
