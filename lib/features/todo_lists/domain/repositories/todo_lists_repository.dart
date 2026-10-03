import '../../data/models/todo_list_response_dto.dart';

abstract class TodoListsRepository {
  Future<List<TodoListResponseDto>> getTodoLists();
  Future<TodoListResponseDto> getTodoListById(String id);
  Future<TodoListResponseDto> createTodoList(String name, String? colorCode);
  Future<TodoListResponseDto> updateTodoList(String id, String name, String? colorCode);
  Future<void> deleteTodoList(String id);
}

