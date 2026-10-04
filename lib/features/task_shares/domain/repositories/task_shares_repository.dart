import '../../../tasks/data/models/todo_item_response_dto.dart';
import '../../data/models/share_task_request.dart';
import '../../data/models/share_task_response_dto.dart';

abstract class TaskSharesRepository {
  Future<List<SharedUserItemDto>> getTaskShares(String taskId);
  Future<ShareTaskResponseDto> shareTask(String taskId, ShareTaskRequest request);
  Future<void> removeCollaborator(String taskId, String userId);
  Future<void> leaveSharedTask(String taskId);
}

