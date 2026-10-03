import '../../data/models/create_todo_item_request.dart';
import '../../data/models/paginated_todo_items_response_dto.dart';
import '../../data/models/todo_item_filter_dto.dart';
import '../../data/models/todo_item_response_dto.dart';
import '../../data/models/update_todo_item_request.dart';

abstract class TodoItemsRepository {
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
}
