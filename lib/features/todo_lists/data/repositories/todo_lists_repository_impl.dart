import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/todo_lists_repository.dart';
import '../datasources/todo_lists_remote_data_source.dart';
import '../models/create_todo_list_request.dart';
import '../models/todo_list_response_dto.dart';
import '../models/update_todo_list_request.dart';

class TodoListsRepositoryImpl implements TodoListsRepository {
  final TodoListsRemoteDataSource remoteDataSource;

  TodoListsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TodoListResponseDto>> getTodoLists() async {
    try {
      return await remoteDataSource.getTodoLists();
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Listeler yüklenirken bir hata oluştu.');
    }
  }

  @override
  Future<TodoListResponseDto> getTodoListById(String id) async {
    try {
      return await remoteDataSource.getTodoListById(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Liste detayları alınamadı.');
    }
  }

  @override
  Future<TodoListResponseDto> createTodoList(String name, String? colorCode) async {
    try {
      final request = CreateTodoListRequest(name: name, colorCode: colorCode);
      return await remoteDataSource.createTodoList(request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Liste oluşturulamadı.');
    }
  }

  @override
  Future<TodoListResponseDto> updateTodoList(
    String id,
    String name,
    String? colorCode,
  ) async {
    try {
      final request = UpdateTodoListRequest(name: name, colorCode: colorCode);
      return await remoteDataSource.updateTodoList(id, request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Liste güncellenemedi.');
    }
  }

  @override
  Future<void> deleteTodoList(String id) async {
    try {
      await remoteDataSource.deleteTodoList(id);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(message: 'Liste silinemedi.');
    }
  }
}
