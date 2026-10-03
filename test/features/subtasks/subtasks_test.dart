import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/features/subtasks/data/models/subtask_response_dto.dart';
import 'package:todo_app_mobile/features/subtasks/domain/repositories/subtasks_repository.dart';
import 'package:todo_app_mobile/features/subtasks/presentation/cubits/subtasks_cubit.dart';
import 'package:todo_app_mobile/features/subtasks/presentation/cubits/subtasks_state.dart';

class MockSubtasksRepository implements SubtasksRepository {
  List<SubtaskResponseDto> mockItems = [];
  bool shouldThrow = false;

  @override
  Future<List<SubtaskResponseDto>> getSubtasks(String taskId) async {
    if (shouldThrow) throw Exception('API Error');
    return mockItems.where((s) => s.taskId == taskId).toList();
  }

  @override
  Future<SubtaskResponseDto> createSubtask(String taskId, String title) async {
    if (shouldThrow) throw Exception('API Error');
    final newSubtask = SubtaskResponseDto(
      id: 'sub-new',
      taskId: taskId,
      title: title,
      status: 'Open',
      createdAt: DateTime.now(),
    );
    mockItems.add(newSubtask);
    return newSubtask;
  }

  @override
  Future<SubtaskResponseDto> toggleComplete(String subtaskId) async {
    if (shouldThrow) throw Exception('API Error');
    final idx = mockItems.indexWhere((s) => s.id == subtaskId);
    final current = mockItems[idx];
    final toggled = current.copyWith(
      status: current.isCompleted ? 'Open' : 'Completed',
    );
    mockItems[idx] = toggled;
    return toggled;
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    if (shouldThrow) throw Exception('API Error');
    mockItems.removeWhere((s) => s.id == subtaskId);
  }
}

void main() {
  late MockSubtasksRepository repository;

  final sampleSubtask = SubtaskResponseDto(
    id: 'sub-1',
    taskId: 'task-1',
    title: 'Adım 1',
    status: 'Open',
    createdAt: DateTime.now(),
  );

  setUp(() {
    repository = MockSubtasksRepository();
    repository.mockItems = [sampleSubtask];
  });

  group('SubtaskResponseDto Tests', () {
    test('Parses JSON correctly and calculates isCompleted', () {
      final json = {
        'id': 'sub-test',
        'taskId': 'task-test',
        'title': 'Test Subtask',
        'status': 'Completed',
        'createdAt': '2026-10-01T10:00:00Z',
      };
      final dto = SubtaskResponseDto.fromJson(json);
      expect(dto.id, 'sub-test');
      expect(dto.title, 'Test Subtask');
      expect(dto.isCompleted, true);
    });
  });

  group('SubtasksCubit Tests', () {
    test('loadSubtasks fetches items and calculates counts', () async {
      final cubit = SubtasksCubit(repository: repository);
      await cubit.loadSubtasks('task-1');

      expect(cubit.state.status, SubtasksStatus.success);
      expect(cubit.state.items.length, 1);
      expect(cubit.state.totalCount, 1);
      expect(cubit.state.completedCount, 0);
      expect(cubit.state.progressRatio, 0.0);
    });

    test('addSubtask creates new subtask and updates list', () async {
      final cubit = SubtasksCubit(repository: repository);
      await cubit.loadSubtasks('task-1');

      final success = await cubit.addSubtask('task-1', 'Yeni Adım');
      expect(success, true);
      expect(cubit.state.items.length, 2);
      expect(cubit.state.items.last.title, 'Yeni Adım');
    });

    test('toggleComplete toggles subtask completion and progress', () async {
      final cubit = SubtasksCubit(repository: repository);
      await cubit.loadSubtasks('task-1');

      await cubit.toggleComplete('sub-1');
      expect(cubit.state.items.first.isCompleted, true);
      expect(cubit.state.completedCount, 1);
      expect(cubit.state.progressRatio, 1.0);

      await cubit.toggleComplete('sub-1');
      expect(cubit.state.items.first.isCompleted, false);
      expect(cubit.state.completedCount, 0);
      expect(cubit.state.progressRatio, 0.0);
    });

    test('deleteSubtask removes subtask from items', () async {
      final cubit = SubtasksCubit(repository: repository);
      await cubit.loadSubtasks('task-1');

      final success = await cubit.deleteSubtask('sub-1');
      expect(success, true);
      expect(cubit.state.items.isEmpty, true);
      expect(cubit.state.totalCount, 0);
    });
  });
}

