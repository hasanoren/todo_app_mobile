import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/features/tasks/data/models/create_todo_item_request.dart';
import 'package:todo_app_mobile/features/tasks/data/models/paginated_todo_items_response_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_filter_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_response_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/update_todo_item_request.dart';
import 'package:todo_app_mobile/features/tasks/domain/entities/todo_item_enums.dart';
import 'package:todo_app_mobile/features/tasks/domain/repositories/todo_items_repository.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/task_detail_cubit.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/task_detail_state.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/task_form_cubit.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/task_form_state.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/tasks_cubit.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/tasks_state.dart';

class MockTodoItemsRepository implements TodoItemsRepository {
  List<TodoItemResponseDto> mockItems = [];
  bool shouldThrow = false;

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTodoItems(
    TodoItemFilterDto filter,
  ) async {
    if (shouldThrow) throw Exception('API Error');
    final filtered = filter.search != null && filter.search!.isNotEmpty
        ? mockItems
              .where(
                (i) => i.title.toLowerCase().contains(
                  filter.search!.toLowerCase(),
                ),
              )
              .toList()
        : mockItems;

    return PaginatedResponseDto(
      items: filtered,
      page: filter.page,
      pageSize: filter.pageSize,
      totalCount: filtered.length,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  @override
  Future<TodoItemResponseDto> getTodoItemById(String id) async {
    if (shouldThrow) throw Exception('API Error');
    return mockItems.firstWhere((i) => i.id == id);
  }

  @override
  Future<TodoItemResponseDto> createTodoItem(
    CreateTodoItemRequest request,
  ) async {
    if (shouldThrow) throw Exception('API Error');
    final newItem = TodoItemResponseDto(
      id: 'mock-id-new',
      title: request.title,
      description: request.description,
      dueDate: request.dueDate,
      status: 'Open',
      priority: 'Medium',
      todoListId: request.todoListId,
      ownerId: 'user-1',
      isOwner: true,
      createdAt: DateTime.now(),
      isDeleted: false,
    );
    mockItems.add(newItem);
    return newItem;
  }

  @override
  Future<TodoItemResponseDto> updateTodoItem(
    String id,
    UpdateTodoItemRequest request,
  ) async {
    if (shouldThrow) throw Exception('API Error');
    final idx = mockItems.indexWhere((i) => i.id == id);
    final updated = mockItems[idx].copyWith(
      title: request.title,
      description: request.description,
      dueDate: request.dueDate,
      priority: TaskPriority.values
          .firstWhere((p) => p.value == request.priority)
          .apiName,
      todoListId: request.todoListId,
    );
    mockItems[idx] = updated;
    return updated;
  }

  @override
  Future<TodoItemResponseDto> toggleComplete(String id) async {
    if (shouldThrow) throw Exception('API Error');
    final idx = mockItems.indexWhere((i) => i.id == id);
    final current = mockItems[idx];
    final toggled = current.copyWith(
      status: current.isCompleted ? 'Open' : 'Completed',
    );
    mockItems[idx] = toggled;
    return toggled;
  }

  @override
  Future<void> deleteTodoItem(String id) async {
    if (shouldThrow) throw Exception('API Error');
    mockItems.removeWhere((i) => i.id == id);
  }

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTrashItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) throw Exception('API Error');
    return PaginatedResponseDto(
      items: const [],
      page: page,
      pageSize: pageSize,
      totalCount: 0,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  @override
  Future<TodoItemResponseDto> restoreTodoItem(String id) async {
    if (shouldThrow) throw Exception('API Error');
    return mockItems.firstWhere((i) => i.id == id);
  }

  @override
  Future<void> permanentDeleteTodoItem(String id) async {
    if (shouldThrow) throw Exception('API Error');
    mockItems.removeWhere((i) => i.id == id);
  }
}

void main() {
  late MockTodoItemsRepository repository;

  final sampleTask = TodoItemResponseDto(
    id: 'task-1',
    title: 'Görevi Tamamla',
    description: 'Açıklama detayı',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    status: 'Open',
    priority: 'High',
    ownerId: 'user-1',
    isOwner: true,
    createdAt: DateTime.now(),
    isDeleted: false,
  );

  setUp(() {
    repository = MockTodoItemsRepository();
    repository.mockItems = [sampleTask];
  });

  group('TodoItemResponseDto Model Tests', () {
    test('Correctly parses JSON with string enums and calculates overdue', () {
      final json = {
        'id': 'test-uuid',
        'title': 'Test Görevi',
        'description': 'Açıklama',
        'dueDate': '2026-10-01T12:00:00Z',
        'status': 'Open',
        'priority': 'High',
        'ownerId': 'owner-uuid',
        'isOwner': true,
        'createdAt': '2026-09-01T10:00:00Z',
        'isDeleted': false,
        'subTasks': [
          {
            'id': 'sub-1',
            'taskId': 'test-uuid',
            'title': 'Alt Adım 1',
            'status': 'Completed',
            'createdAt': '2026-09-01T10:00:00Z',
          },
        ],
        'tags': [
          {'id': 'tag-1', 'name': 'Acil', 'createdAt': '2026-09-01T10:00:00Z'},
        ],
        'sharedWith': [],
      };

      final dto = TodoItemResponseDto.fromJson(json);
      expect(dto.id, 'test-uuid');
      expect(dto.title, 'Test Görevi');
      expect(dto.taskPriority, TaskPriority.high);
      expect(dto.taskStatus, TaskStatus.open);
      expect(dto.isCompleted, false);
      expect(dto.subTasks.length, 1);
      expect(dto.subTasks.first.isCompleted, true);
      expect(dto.tags.length, 1);
      expect(dto.tags.first.name, 'Acil');
    });

    test('TaskPriority correctly maps backend values and strings', () {
      expect(TaskPriority.fromServer(1), TaskPriority.low);
      expect(TaskPriority.fromServer(2), TaskPriority.medium);
      expect(TaskPriority.fromServer(3), TaskPriority.high);
      expect(TaskPriority.fromServer('Low'), TaskPriority.low);
      expect(TaskPriority.fromServer('Medium'), TaskPriority.medium);
      expect(TaskPriority.fromServer('High'), TaskPriority.high);
      // Legacy or boundary values fallback safely
      expect(TaskPriority.fromServer(0), TaskPriority.low);
      expect(TaskPriority.fromServer(4), TaskPriority.high);
      expect(TaskPriority.fromServer('Urgent'), TaskPriority.high);
      expect(TaskPriority.fromServer(null), TaskPriority.medium);
    });

    test('TodoItemFilterDto correctly handles priority updates and clearing', () {
      final initial = const TodoItemFilterDto();
      expect(initial.priority, null);

      final withLow = initial.copyWith(priority: TaskPriority.low.value);
      expect(withLow.priority, 1);
      expect(withLow.toQueryParams()['priority'], 1);

      // Switching directly to High overrides Low without conflict
      final withHigh = withLow.copyWith(priority: TaskPriority.high.value);
      expect(withHigh.priority, 3);
      expect(withHigh.toQueryParams()['priority'], 3);

      // Clearing priority sets it to null
      final cleared = withHigh.copyWith(clearPriority: true);
      expect(cleared.priority, null);
      expect(cleared.toQueryParams().containsKey('priority'), false);
    });
  });

  group('TasksCubit Tests', () {
    test('loadTasks fetches items and emits success', () async {
      final cubit = TasksCubit(repository: repository);
      await cubit.loadTasks();

      expect(cubit.state.status, TasksStatus.success);
      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.title, 'Görevi Tamamla');
    });

    test('toggleComplete toggles status in items list', () async {
      final cubit = TasksCubit(repository: repository);
      await cubit.loadTasks();

      await cubit.toggleComplete('task-1');
      expect(cubit.state.items.first.isCompleted, true);

      await cubit.toggleComplete('task-1');
      expect(cubit.state.items.first.isCompleted, false);
    });

    test('deleteTask removes item from state list', () async {
      final cubit = TasksCubit(repository: repository);
      await cubit.loadTasks();

      final result = await cubit.deleteTask('task-1');
      expect(result, true);
      expect(cubit.state.items.isEmpty, true);
    });

    test('updateSearch filters tasks', () async {
      final cubit = TasksCubit(repository: repository);
      await cubit.updateSearch('Görevi');
      expect(cubit.state.items.length, 1);

      await cubit.updateSearch('BulunamayacakKelime');
      expect(cubit.state.items.isEmpty, true);
    });
  });

  group('TaskFormCubit Tests', () {
    test('submit validates empty title', () async {
      final cubit = TaskFormCubit(repository: repository);
      cubit.initializeForCreate();
      await cubit.submit();

      expect(cubit.state.status, TaskFormStatus.error);
      expect(cubit.state.errorMessage, contains('boş bırakılamaz'));
    });

    test('submit creates task successfully when valid', () async {
      final cubit = TaskFormCubit(repository: repository);
      cubit.initializeForCreate();
      cubit.titleChanged('Yeni Görev Başlığı');
      cubit.descriptionChanged('Açıklama');
      cubit.priorityChanged(TaskPriority.high);

      await cubit.submit();

      expect(cubit.state.status, TaskFormStatus.success);
      expect(cubit.state.resultTask?.title, 'Yeni Görev Başlığı');
    });

    test('submit updates existing task when isEditing', () async {
      final cubit = TaskFormCubit(repository: repository);
      cubit.initializeForEdit(sampleTask);
      cubit.titleChanged('Güncellenmiş Başlık');

      await cubit.submit();

      expect(cubit.state.status, TaskFormStatus.success);
      expect(cubit.state.resultTask?.title, 'Güncellenmiş Başlık');
    });
  });

  group('TaskDetailCubit Tests', () {
    test('loadTask fetches single task', () async {
      final cubit = TaskDetailCubit(repository: repository);
      await cubit.loadTask('task-1');

      expect(cubit.state.status, TaskDetailStatus.success);
      expect(cubit.state.task?.id, 'task-1');
    });

    test('toggleComplete toggles detail task status', () async {
      final cubit = TaskDetailCubit(repository: repository);
      await cubit.loadTask('task-1');

      await cubit.toggleComplete();
      expect(cubit.state.task?.isCompleted, true);
    });

    test('deleteTask marks state as deleted', () async {
      final cubit = TaskDetailCubit(repository: repository);
      await cubit.loadTask('task-1');

      final success = await cubit.deleteTask();
      expect(success, true);
      expect(cubit.state.status, TaskDetailStatus.deleted);
    });
  });
}
