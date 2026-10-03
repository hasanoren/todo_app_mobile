import 'package:todo_app_mobile/features/tasks/data/models/paginated_todo_items_response_dto.dart';
import '../../data/models/tag_response_dto.dart';

abstract class TagsRepository {
  Future<List<TagResponseDto>> getSystemTags();
  Future<TagResponseDto> createTag(String name);
  Future<PaginatedTodoItemsResponseDto> getTasksByTag(
    String tagId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<List<TagResponseDto>> getTaskTags(String taskId);
  Future<void> attachTagToTask(String taskId, String tagId);
  Future<void> detachTagFromTask(String taskId, String tagId);
}
