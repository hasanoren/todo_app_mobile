import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app_mobile/core/errors/failure.dart';
import 'package:todo_app_mobile/features/tasks/data/models/create_todo_item_request.dart';
import 'package:todo_app_mobile/features/tasks/data/models/paginated_todo_items_response_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_filter_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_response_dto.dart';
import 'package:todo_app_mobile/features/tasks/data/models/update_todo_item_request.dart';
import 'package:todo_app_mobile/features/tasks/domain/repositories/todo_items_repository.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/trash_cubit.dart';
import 'package:todo_app_mobile/features/tasks/presentation/cubits/trash_state.dart';

class MockTrashTodoItemsRepository implements TodoItemsRepository {
  List<TodoItemResponseDto> trashItems = [];
  bool shouldThrow = false;
  String errorMessage = 'Sunucu hatası';

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTrashItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    return PaginatedResponseDto(
      items: List.from(trashItems),
      page: page,
      pageSize: pageSize,
      totalCount: trashItems.length,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  @override
  Future<TodoItemResponseDto> restoreTodoItem(String id) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    final item = trashItems.firstWhere((i) => i.id == id);
    trashItems.removeWhere((i) => i.id == id);
    return item;
  }

  @override
  Future<void> permanentDeleteTodoItem(String id) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    trashItems.removeWhere((i) => i.id == id);
  }

  @override
  Future<TodoItemResponseDto> createTodoItem(CreateTodoItemRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> deleteTodoItem(String id) => throw UnimplementedError();

  @override
  Future<TodoItemResponseDto> getTodoItemById(String id) =>
      throw UnimplementedError();

  @override
  Future<PaginatedResponseDto<TodoItemResponseDto>> getTodoItems(
    TodoItemFilterDto filter,
  ) =>
      throw UnimplementedError();

  @override
  Future<TodoItemResponseDto> toggleComplete(String id) =>
      throw UnimplementedError();

  @override
  Future<TodoItemResponseDto> updateTodoItem(
    String id,
    UpdateTodoItemRequest request,
  ) =>
      throw UnimplementedError();
}

void main() {
  group('TrashCubit Tests', () {
    late MockTrashTodoItemsRepository repository;
    late TrashCubit cubit;

    final dummyTrashItem = TodoItemResponseDto(
      id: 'task-trash-1',
      title: 'Eski Silinmiş Görev',
      description: 'Açıklama',
      status: 'Open',
      priority: 'High',
      ownerId: 'user-1',
      isOwner: true,
      createdAt: DateTime.parse('2026-03-30T10:00:00Z'),
      deletedAt: DateTime.parse('2026-03-30T12:00:00Z'),
      isDeleted: true,
    );

    setUp(() {
      repository = MockTrashTodoItemsRepository();
      cubit = TrashCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status and empty items', () {
      expect(cubit.state.status, TrashStatus.initial);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.totalCount, 0);
    });

    test('loadTrash succeeds and populates items', () async {
      repository.trashItems = [dummyTrashItem];

      await cubit.loadTrash();

      expect(cubit.state.status, TrashStatus.loaded);
      expect(cubit.state.items.length, 1);
      expect(cubit.state.totalCount, 1);
      expect(cubit.state.items.first.id, 'task-trash-1');
    });

    test('loadTrash fails and sets errorMessage', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Çöp kutusuna erişilemiyor';

      await cubit.loadTrash();

      expect(cubit.state.status, TrashStatus.error);
      expect(cubit.state.errorMessage, 'Çöp kutusuna erişilemiyor');
    });

    test('restoreItem removes restored task from trash list', () async {
      repository.trashItems = [dummyTrashItem];
      await cubit.loadTrash();
      expect(cubit.state.items.length, 1);

      final success = await cubit.restoreItem('task-trash-1');

      expect(success, true);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.totalCount, 0);
      expect(cubit.state.successMessage, contains('geri yüklendi'));
    });

    test('permanentDeleteItem removes task from trash list permanently',
        () async {
      repository.trashItems = [dummyTrashItem];
      await cubit.loadTrash();
      expect(cubit.state.items.length, 1);

      final success = await cubit.permanentDeleteItem('task-trash-1');

      expect(success, true);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.totalCount, 0);
      expect(cubit.state.successMessage, 'Görev kalıcı olarak silindi.');
    });
  });
}

