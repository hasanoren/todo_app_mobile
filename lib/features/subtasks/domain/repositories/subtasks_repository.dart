import '../../data/models/subtask_response_dto.dart';

abstract class SubtasksRepository {
  Future<List<SubtaskResponseDto>> getSubtasks(String taskId);
  Future<SubtaskResponseDto> createSubtask(String taskId, String title);
  Future<SubtaskResponseDto> toggleComplete(String subtaskId);
  Future<void> deleteSubtask(String subtaskId);
}
