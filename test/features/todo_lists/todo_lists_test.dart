import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/core/errors/failure.dart';
import 'package:todo_app_mobile/features/todo_lists/data/models/todo_list_response_dto.dart';
import 'package:todo_app_mobile/features/todo_lists/domain/repositories/todo_lists_repository.dart';
import 'package:todo_app_mobile/features/todo_lists/presentation/cubits/todo_list_form_cubit.dart';
import 'package:todo_app_mobile/features/todo_lists/presentation/cubits/todo_lists_cubit.dart';

class FakeTodoListsRepository implements TodoListsRepository {
  bool shouldFail = false;
  final List<TodoListResponseDto> lists = [];

  @override
  Future<List<TodoListResponseDto>> getTodoLists() async {
    if (shouldFail) throw const ServerFailure(message: 'Sunucu hatası');
    return lists;
  }

  @override
  Future<TodoListResponseDto> getTodoListById(String id) async {
    if (shouldFail) throw const ServerFailure(message: 'Liste bulunamadı');
    return lists.firstWhere((l) => l.id == id);
  }

  @override
  Future<TodoListResponseDto> createTodoList(
    String name,
    String? colorCode,
  ) async {
    if (shouldFail) throw const ServerFailure(message: 'Liste oluşturulamadı');
    final newList = TodoListResponseDto(
      id: 'id-${lists.length + 1}',
      name: name,
      colorCode: colorCode,
      ownerId: 'owner-123',
      createdAt: DateTime.now(),
    );
    lists.add(newList);
    return newList;
  }

  @override
  Future<TodoListResponseDto> updateTodoList(
    String id,
    String name,
    String? colorCode,
  ) async {
    if (shouldFail) throw const ServerFailure(message: 'Liste güncellenemedi');
    final index = lists.indexWhere((l) => l.id == id);
    final updated = TodoListResponseDto(
      id: id,
      name: name,
      colorCode: colorCode,
      ownerId: 'owner-123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (index != -1) {
      lists[index] = updated;
    }
    return updated;
  }

  @override
  Future<void> deleteTodoList(String id) async {
    if (shouldFail) throw const ServerFailure(message: 'Liste silinemedi');
    lists.removeWhere((l) => l.id == id);
  }
}

void main() {
  group('TodoListsCubit', () {
    late FakeTodoListsRepository repository;
    late TodoListsCubit cubit;

    setUp(() {
      repository = FakeTodoListsRepository();
      cubit = TodoListsCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadLists loads lists successfully', () async {
      repository.lists.add(
        TodoListResponseDto(
          id: 'list-1',
          name: 'İş Projeleri',
          colorCode: '#3B82F6',
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
        ),
      );

      await cubit.loadLists();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.lists.length, 1);
      expect(cubit.state.lists.first.name, 'İş Projeleri');
      expect(cubit.state.errorMessage, isNull);
    });

    test('loadLists emits error on failure', () async {
      repository.shouldFail = true;

      await cubit.loadLists();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.errorMessage, 'Sunucu hatası');
    });

    test('deleteList removes item and emits successMessage', () async {
      final item = TodoListResponseDto(
        id: 'list-1',
        name: 'Silinecek',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
      );
      repository.lists.add(item);
      await cubit.loadLists();

      final result = await cubit.deleteList('list-1');

      expect(result, true);
      expect(cubit.state.lists.isEmpty, true);
      expect(cubit.state.successMessage, 'Liste başarıyla silindi.');
    });

    test('addList prepends item to list', () {
      final item = TodoListResponseDto(
        id: 'list-new',
        name: 'Yeni Liste',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
      );

      cubit.addList(item);

      expect(cubit.state.lists.length, 1);
      expect(cubit.state.lists.first.id, 'list-new');
    });

    test('updateListInState updates target item', () {
      final item = TodoListResponseDto(
        id: 'list-1',
        name: 'Eski İsim',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
      );
      cubit.addList(item);

      final updated = item.copyWith(name: 'Yeni İsim');
      cubit.updateListInState(updated);

      expect(cubit.state.lists.first.name, 'Yeni İsim');
    });
  });

  group('TodoListFormCubit', () {
    late FakeTodoListsRepository repository;

    setUp(() {
      repository = FakeTodoListsRepository();
    });

    test('validates empty list name', () async {
      final formCubit = TodoListFormCubit(repository: repository);

      final result = await formCubit.submit();

      expect(result, false);
      expect(formCubit.state.nameError, 'Liste adı boş bırakılamaz.');
      formCubit.close();
    });

    test('creates list with valid name and color', () async {
      final formCubit = TodoListFormCubit(repository: repository);

      formCubit.nameChanged('Kişisel');
      formCubit.colorChanged('#10B981');

      final result = await formCubit.submit();

      expect(result, true);
      expect(formCubit.state.resultList, isNotNull);
      expect(formCubit.state.resultList?.name, 'Kişisel');
      expect(formCubit.state.resultList?.colorCode, '#10B981');
      formCubit.close();
    });

    test('updates existing list in edit mode', () async {
      final initial = TodoListResponseDto(
        id: 'edit-1',
        name: 'Önceki İsim',
        colorCode: '#FF5733',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
      );

      final formCubit = TodoListFormCubit(
        repository: repository,
        initialList: initial,
      );

      expect(formCubit.state.isEdit, true);
      expect(formCubit.state.name, 'Önceki İsim');

      formCubit.nameChanged('Sonraki İsim');
      final result = await formCubit.submit();

      expect(result, true);
      expect(formCubit.state.resultList?.name, 'Sonraki İsim');
      formCubit.close();
    });
  });
}
