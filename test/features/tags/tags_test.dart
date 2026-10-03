import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/features/tags/data/models/create_tag_request.dart';
import 'package:todo_app_mobile/features/tags/data/models/tag_response_dto.dart';
import 'package:todo_app_mobile/features/tags/data/models/tags_collection_response_dto.dart';
import 'package:todo_app_mobile/features/tags/domain/repositories/tags_repository.dart';
import 'package:todo_app_mobile/features/tags/presentation/cubits/system_tags_cubit.dart';
import 'package:todo_app_mobile/features/tags/presentation/cubits/system_tags_state.dart';
import 'package:todo_app_mobile/features/tags/presentation/cubits/tagged_tasks_cubit.dart';
import 'package:todo_app_mobile/features/tags/presentation/cubits/tagged_tasks_state.dart';
import 'package:todo_app_mobile/features/tags/presentation/cubits/task_tags_cubit.dart';
import 'package:todo_app_mobile/features/tags/presentation/cubits/task_tags_state.dart';
import 'package:todo_app_mobile/features/tasks/data/models/paginated_todo_items_response_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_response_dto.dart';

class MockTagsRepository implements TagsRepository {
  List<TagResponseDto> systemTags = [];
  Map<String, List<TagResponseDto>> taskTags = {};
  List<TodoItemResponseDto> taggedTasks = [];
  bool shouldThrow = false;

  @override
  Future<List<TagResponseDto>> getSystemTags() async {
    if (shouldThrow) throw Exception('API Error');
    return List<TagResponseDto>.from(systemTags);
  }

  @override
  Future<TagResponseDto> createTag(String name) async {
    if (shouldThrow) throw Exception('API Error');
    final newTag = TagResponseDto(
      id: 'tag-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
    );
    systemTags.add(newTag);
    return newTag;
  }

  @override
  Future<List<TagResponseDto>> getTaskTags(String taskId) async {
    if (shouldThrow) throw Exception('API Error');
    return List<TagResponseDto>.from(taskTags[taskId] ?? []);
  }

  @override
  Future<void> attachTagToTask(String taskId, String tagId) async {
    if (shouldThrow) throw Exception('API Error');
    final tag = systemTags.firstWhere((t) => t.id == tagId);
    final current = taskTags[taskId] ?? [];
    if (!current.any((t) => t.id == tagId)) {
      taskTags[taskId] = [...current, tag];
    }
  }

  @override
  Future<void> detachTagFromTask(String taskId, String tagId) async {
    if (shouldThrow) throw Exception('API Error');
    final current = taskTags[taskId] ?? [];
    taskTags[taskId] = current.where((t) => t.id != tagId).toList();
  }

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTasksByTag(
    String tagId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) throw Exception('API Error');
    return PaginatedResponseDto<TodoItemResponseDto>(
      items: taggedTasks,
      page: page,
      pageSize: pageSize,
      totalCount: taggedTasks.length,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }
}

void main() {
  late MockTagsRepository repository;

  final sampleTag = TagResponseDto(
    id: 'tag-1',
    name: 'Frontend',
    createdAt: DateTime.parse('2026-03-01T12:00:00Z'),
  );

  setUp(() {
    repository = MockTagsRepository();
    repository.systemTags = [sampleTag];
    repository.taskTags['task-1'] = [sampleTag];
  });

  group('Tag DTO Tests', () {
    test('TagResponseDto parses from JSON and serializes to JSON', () {
      final json = {
        'id': 'tag-99',
        'name': 'DevOps',
        'createdAt': '2026-10-01T12:00:00.000Z',
      };
      final dto = TagResponseDto.fromJson(json);
      expect(dto.id, 'tag-99');
      expect(dto.name, 'DevOps');
      expect(dto.toJson()['name'], 'DevOps');
    });

    test('TagsCollectionResponseDto parses Map wrapper and direct List', () {
      final mapData = {
        'items': [
          {'id': 't1', 'name': 'Tag1', 'createdAt': '2026-10-01T12:00:00.000Z'}
        ]
      };
      final fromMap = TagsCollectionResponseDto.fromJson(mapData);
      expect(fromMap.items.length, 1);
      expect(fromMap.items.first.name, 'Tag1');

      final listData = [
        {'id': 't2', 'name': 'Tag2', 'createdAt': '2026-10-01T12:00:00.000Z'}
      ];
      final fromList = TagsCollectionResponseDto.fromJson(listData);
      expect(fromList.items.length, 1);
      expect(fromList.items.first.name, 'Tag2');
    });

    test('CreateTagRequest serializes name correctly', () {
      const req = CreateTagRequest(name: '  Mobile  ');
      expect(req.toJson()['name'], 'Mobile');
    });
  });

  group('TaskTagsCubit Tests', () {
    test('loadTags loads tags for a specific task', () async {
      final cubit = TaskTagsCubit(
        tagsRepository: repository,
        taskId: 'task-1',
      );

      await cubit.loadTags();
      expect(cubit.state, isA<TaskTagsLoaded>());
      final loaded = cubit.state as TaskTagsLoaded;
      expect(loaded.tags.length, 1);
      expect(loaded.tags.first.name, 'Frontend');
    });

    test('attachTag attaches a tag idempotently', () async {
      final newTag = TagResponseDto(
        id: 'tag-2',
        name: 'Backend',
        createdAt: DateTime.now(),
      );
      repository.systemTags.add(newTag);

      final cubit = TaskTagsCubit(
        tagsRepository: repository,
        taskId: 'task-1',
        initialTags: [sampleTag],
      );

      final success = await cubit.attachTag(newTag);
      expect(success, true);
      final loaded = cubit.state as TaskTagsLoaded;
      expect(loaded.tags.length, 2);

      // Attaching again should be idempotent
      final secondSuccess = await cubit.attachTag(newTag);
      expect(secondSuccess, true);
      expect((cubit.state as TaskTagsLoaded).tags.length, 2);
    });

    test('detachTag detaches a tag from task', () async {
      final cubit = TaskTagsCubit(
        tagsRepository: repository,
        taskId: 'task-1',
        initialTags: [sampleTag],
      );

      final success = await cubit.detachTag('tag-1');
      expect(success, true);
      final loaded = cubit.state as TaskTagsLoaded;
      expect(loaded.tags.isEmpty, true);
    });
  });

  group('SystemTagsCubit Tests', () {
    test('loadSystemTags loads all system tags', () async {
      final cubit = SystemTagsCubit(tagsRepository: repository);
      await cubit.loadSystemTags();

      expect(cubit.state, isA<SystemTagsLoaded>());
      final loaded = cubit.state as SystemTagsLoaded;
      expect(loaded.tags.length, 1);
      expect(loaded.tags.first.name, 'Frontend');
    });

    test('createTag creates and appends new tag', () async {
      final cubit = SystemTagsCubit(tagsRepository: repository);
      await cubit.loadSystemTags();

      final created = await cubit.createTag('QA & Testing');
      expect(created, isNotNull);
      expect(created!.name, 'QA & Testing');

      final loaded = cubit.state as SystemTagsLoaded;
      expect(loaded.tags.length, 2);
      expect(loaded.newlyCreatedTag?.name, 'QA & Testing');
    });
  });

  group('TaggedTasksCubit Tests', () {
    test('loadTasks fetches tasks associated with tag', () async {
      final sampleTask = TodoItemResponseDto(
        id: 'todo-1',
        title: 'Tagged task',
        status: 'Open',
        priority: 'High',
        ownerId: 'user-1',
        isOwner: true,
        createdAt: DateTime.now(),
        isDeleted: false,
      );
      repository.taggedTasks = [sampleTask];

      final cubit = TaggedTasksCubit(
        tagsRepository: repository,
        tagId: 'tag-1',
      );

      await cubit.loadTasks();
      expect(cubit.state.status, TaggedTasksStatus.success);
      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.title, 'Tagged task');
    });
  });
}
