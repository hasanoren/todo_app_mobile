import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/core/errors/failure.dart';
import 'package:todo_app_mobile/features/task_shares/data/models/share_task_request.dart';
import 'package:todo_app_mobile/features/task_shares/data/models/share_task_response_dto.dart';
import 'package:todo_app_mobile/features/task_shares/data/models/shares_collection_response_dto.dart';
import 'package:todo_app_mobile/features/task_shares/domain/repositories/task_shares_repository.dart';
import 'package:todo_app_mobile/features/task_shares/presentation/cubits/task_shares_cubit.dart';
import 'package:todo_app_mobile/features/task_shares/presentation/cubits/task_shares_state.dart';
import 'package:todo_app_mobile/features/tasks/data/models/todo_item_response_dto.dart';

class MockTaskSharesRepository implements TaskSharesRepository {
  List<SharedUserItemDto> mockShares = [];
  bool shouldThrow = false;
  String errorMessage = 'Hata oluştu';

  @override
  Future<List<SharedUserItemDto>> getTaskShares(String taskId) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    return List.from(mockShares);
  }

  @override
  Future<ShareTaskResponseDto> shareTask(
    String taskId,
    ShareTaskRequest request,
  ) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    final newUser = SharedUserItemDto(
      userId: 'user-${mockShares.length + 1}',
      email: request.email,
      sharedAt: DateTime.now(),
    );
    mockShares.add(newUser);
    return const ShareTaskResponseDto(message: 'Görev başarıyla paylaşıldı.');
  }

  @override
  Future<void> removeCollaborator(String taskId, String userId) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
    mockShares.removeWhere((u) => u.userId == userId);
  }

  @override
  Future<void> leaveSharedTask(String taskId) async {
    if (shouldThrow) throw ServerFailure(message: errorMessage);
  }
}

void main() {
  group('Task Sharing DTO Tests', () {
    test('ShareTaskRequest serializes email correctly', () {
      const request = ShareTaskRequest(email: ' User@Example.COM ');
      expect(request.toJson(), {'email': 'user@example.com'});
    });

    test('ShareTaskResponseDto parses JSON correctly', () {
      final json = {'message': 'Özel mesaj'};
      final dto = ShareTaskResponseDto.fromJson(json);
      expect(dto.message, 'Özel mesaj');
    });

    test('SharesCollectionResponseDto parses Map wrapper and List correctly', () {
      final listJson = [
        {
          'userId': 'u-1',
          'email': 'test@example.com',
          'sharedAt': '2026-10-01T10:00:00Z',
        }
      ];
      final fromList = SharesCollectionResponseDto.fromJson(listJson);
      expect(fromList.items.length, 1);
      expect(fromList.items.first.email, 'test@example.com');

      final mapJson = {
        'items': [
          {
            'userId': 'u-2',
            'email': 'two@example.com',
            'sharedAt': '2026-10-02T10:00:00Z',
          }
        ]
      };
      final fromMap = SharesCollectionResponseDto.fromJson(mapJson);
      expect(fromMap.items.length, 1);
      expect(fromMap.items.first.userId, 'u-2');
    });
  });

  group('TaskSharesCubit Tests', () {
    late MockTaskSharesRepository repository;
    late TaskSharesCubit cubit;

    setUp(() {
      repository = MockTaskSharesRepository();
      cubit = TaskSharesCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initializeWithShares sets initial shares state', () {
      final initial = [
        SharedUserItemDto(
          userId: 'u-1',
          email: 'initial@example.com',
          sharedAt: DateTime.now(),
        ),
      ];
      cubit.initializeWithShares(initial);
      expect(cubit.state.status, TaskSharesStatus.success);
      expect(cubit.state.shares.length, 1);
      expect(cubit.state.shares.first.email, 'initial@example.com');
    });

    test('loadShares loads shares and emits success', () async {
      repository.mockShares = [
        SharedUserItemDto(
          userId: 'u-1',
          email: 'collab@example.com',
          sharedAt: DateTime.now(),
        ),
      ];

      await cubit.loadShares('task-1');

      expect(cubit.state.status, TaskSharesStatus.success);
      expect(cubit.state.shares.length, 1);
      expect(cubit.state.shares.first.userId, 'u-1');
    });

    test('loadShares emits error on failure', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Yükleme başarısız';

      await cubit.loadShares('task-1');

      expect(cubit.state.status, TaskSharesStatus.error);
      expect(cubit.state.errorMessage, 'Yükleme başarısız');
    });

    test('shareTask validates empty email', () async {
      final success = await cubit.shareTask('task-1', '   ');
      expect(success, false);
      expect(cubit.state.errorMessage, 'Lütfen geçerli bir e-posta adresi girin.');
    });

    test('shareTask shares task and updates state on success', () async {
      final success = await cubit.shareTask('task-1', 'friend@example.com');
      expect(success, true);
      expect(cubit.state.status, TaskSharesStatus.success);
      expect(cubit.state.shares.length, 1);
      expect(cubit.state.shares.first.email, 'friend@example.com');
      expect(cubit.state.successMessage, 'Görev başarıyla paylaşıldı.');
    });

    test('shareTask emits error message on failure', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Kullanıcı bulunamadı';

      final success = await cubit.shareTask('task-1', 'friend@example.com');
      expect(success, false);
      expect(cubit.state.errorMessage, 'Kullanıcı bulunamadı');
    });

    test('removeCollaborator removes user from state list', () async {
      cubit.initializeWithShares([
        SharedUserItemDto(
          userId: 'u-1',
          email: 'removable@example.com',
          sharedAt: DateTime.now(),
        ),
      ]);
      repository.mockShares = [
        SharedUserItemDto(
          userId: 'u-1',
          email: 'removable@example.com',
          sharedAt: DateTime.now(),
        ),
      ];

      final success = await cubit.removeCollaborator('task-1', 'u-1');
      expect(success, true);
      expect(cubit.state.shares.isEmpty, true);
      expect(cubit.state.successMessage, 'Kullanıcı görevden çıkarıldı.');
    });

    test('leaveSharedTask emits leftTask status', () async {
      final success = await cubit.leaveSharedTask('task-1');
      expect(success, true);
      expect(cubit.state.status, TaskSharesStatus.leftTask);
      expect(cubit.state.successMessage, 'Paylaşılan görevden ayrıldınız.');
    });
  });
}

