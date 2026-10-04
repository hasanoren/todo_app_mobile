import '../../data/models/todo_item_activity_response_dto.dart';

abstract class TaskActivitiesRepository {
  Future<List<TodoItemActivityResponseDto>> getActivities(String taskId);
}
