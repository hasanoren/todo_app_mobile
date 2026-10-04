import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/core/errors/api_exception.dart';
import 'package:todo_app_mobile/core/errors/failure.dart';
import 'package:todo_app_mobile/features/task_activities/data/datasources/task_activities_remote_data_source.dart';
import 'package:todo_app_mobile/features/task_activities/data/models/todo_item_activity_response_dto.dart';
import 'package:todo_app_mobile/features/task_activities/data/repositories/task_activities_repository_impl.dart';
import 'package:todo_app_mobile/features/task_activities/domain/repositories/task_activities_repository.dart';
import 'package:todo_app_mobile/features/task_activities/presentation/cubits/task_activities_cubit.dart';
import 'package:todo_app_mobile/features/task_activities/presentation/cubits/task_activities_state.dart';
import 'package:todo_app_mobile/features/task_activities/presentation/widgets/task_activities_section.dart';
import 'package:todo_app_mobile/features/task_activities/presentation/widgets/task_activity_item_tile.dart';

class MockTaskActivitiesDataSource implements TaskActivitiesRemoteDataSource {
  List<TodoItemActivityResponseDto> mockData = [];
  bool shouldThrow = false;
  Object? errorToThrow;

  @override
  Future<List<TodoItemActivityResponseDto>> getActivities(String taskId) async {
    if (shouldThrow) {
      if (errorToThrow != null) throw errorToThrow!;
      throw ApiException(
        statusCode: 500,
        title: 'Server Error',
        detail: 'Hata oluştu',
      );
    }
    return List.from(mockData);
  }
}

class MockTaskActivitiesRepository implements TaskActivitiesRepository {
  List<TodoItemActivityResponseDto> mockActivities = [];
  bool shouldThrow = false;
  Failure? failure;

  @override
  Future<List<TodoItemActivityResponseDto>> getActivities(String taskId) async {
    if (shouldThrow) {
      throw failure ?? const ServerFailure(message: 'Sunucu hatası');
    }
    return List.from(mockActivities);
  }
}

void main() {
  group('TodoItemActivityResponseDto Tests', () {
    test('fromJson parses complete valid JSON correctly', () {
      final json = {
        'id': 'act-1',
        'userId': 'user-1',
        'userEmail': 'test@example.com',
        'action': 'Created',
        'details': 'Görev oluşturuldu',
        'createdAt': '2026-10-04T12:00:00.000Z',
      };

      final dto = TodoItemActivityResponseDto.fromJson(json);

      expect(dto.id, 'act-1');
      expect(dto.userId, 'user-1');
      expect(dto.userEmail, 'test@example.com');
      expect(dto.action, 'Created');
      expect(dto.details, 'Görev oluşturuldu');
      expect(dto.createdAt, DateTime.parse('2026-10-04T12:00:00.000Z'));
    });

    test('fromJson handles null and missing fields gracefully', () {
      final json = <String, dynamic>{};

      final dto = TodoItemActivityResponseDto.fromJson(json);

      expect(dto.id, '');
      expect(dto.userId, '');
      expect(dto.userEmail, '');
      expect(dto.action, '');
      expect(dto.details, isNull);
      expect(dto.createdAt, isA<DateTime>());
    });

    test('toJson serializes correctly', () {
      final now = DateTime.parse('2026-10-04T15:30:00.000Z');
      final dto = TodoItemActivityResponseDto(
        id: 'act-2',
        userId: 'user-2',
        userEmail: 'admin@example.com',
        action: 'Completed',
        details: null,
        createdAt: now,
      );

      final json = dto.toJson();

      expect(json['id'], 'act-2');
      expect(json['userId'], 'user-2');
      expect(json['userEmail'], 'admin@example.com');
      expect(json['action'], 'Completed');
      expect(json['details'], isNull);
      expect(json['createdAt'], now.toIso8601String());
    });

    test('Equatable equality works based on fields', () {
      final now = DateTime.parse('2026-10-04T12:00:00.000Z');
      final dto1 = TodoItemActivityResponseDto(
        id: '1',
        userId: 'u1',
        userEmail: 'a@b.com',
        action: 'Created',
        createdAt: now,
      );
      final dto2 = TodoItemActivityResponseDto(
        id: '1',
        userId: 'u1',
        userEmail: 'a@b.com',
        action: 'Created',
        createdAt: now,
      );

      expect(dto1, equals(dto2));
    });
  });

  group('TaskActivitiesRepositoryImpl Tests', () {
    late MockTaskActivitiesDataSource mockDataSource;
    late TaskActivitiesRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockTaskActivitiesDataSource();
      repository =
          TaskActivitiesRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('getActivities returns activity list from data source', () async {
      mockDataSource.mockData = [
        TodoItemActivityResponseDto(
          id: '1',
          userId: 'u1',
          userEmail: 'u1@test.com',
          action: 'Created',
          createdAt: DateTime.now(),
        ),
      ];

      final result = await repository.getActivities('task-123');

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('getActivities maps ApiException to ServerFailure', () async {
      mockDataSource.shouldThrow = true;
      mockDataSource.errorToThrow = ApiException(
        statusCode: 400,
        title: 'Bad Request',
        detail: 'Yetkisiz erişim',
      );

      expect(
        () => repository.getActivities('task-123'),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            'Yetkisiz erişim',
          ),
        ),
      );
    });

    test('getActivities maps unknown errors to NetworkFailure', () async {
      mockDataSource.shouldThrow = true;
      mockDataSource.errorToThrow = Exception('Socket error');

      expect(
        () => repository.getActivities('task-123'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('TaskActivitiesCubit Tests', () {
    late MockTaskActivitiesRepository mockRepo;
    late TaskActivitiesCubit cubit;

    setUp(() {
      mockRepo = MockTaskActivitiesRepository();
      cubit = TaskActivitiesCubit(repository: mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial state is correct', () {
      expect(cubit.state.status, TaskActivitiesStatus.initial);
      expect(cubit.state.activities, isEmpty);
      expect(cubit.state.errorMessage, isNull);
    });

    test(
        'loadActivities emits [loading, success] and sorts activities newest first',
        () async {
      final older = DateTime.parse('2026-10-01T10:00:00Z');
      final newer = DateTime.parse('2026-10-04T12:00:00Z');

      mockRepo.mockActivities = [
        TodoItemActivityResponseDto(
          id: 'old',
          userId: 'u1',
          userEmail: 'user@test.com',
          action: 'Created',
          createdAt: older,
        ),
        TodoItemActivityResponseDto(
          id: 'new',
          userId: 'u1',
          userEmail: 'user@test.com',
          action: 'Completed',
          createdAt: newer,
        ),
      ];

      final expectedStates = [
        const TaskActivitiesState(status: TaskActivitiesStatus.loading),
        TaskActivitiesState(
          status: TaskActivitiesStatus.success,
          activities: [
            TodoItemActivityResponseDto(
              id: 'new',
              userId: 'u1',
              userEmail: 'user@test.com',
              action: 'Completed',
              createdAt: newer,
            ),
            TodoItemActivityResponseDto(
              id: 'old',
              userId: 'u1',
              userEmail: 'user@test.com',
              action: 'Created',
              createdAt: older,
            ),
          ],
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadActivities('task-1');
    });

    test('loadActivities emits [loading, error] on repository failure',
        () async {
      mockRepo.shouldThrow = true;
      mockRepo.failure = const ServerFailure(message: 'Veriler alınamadı');

      final expectedStates = [
        const TaskActivitiesState(status: TaskActivitiesStatus.loading),
        const TaskActivitiesState(
          status: TaskActivitiesStatus.error,
          errorMessage: 'Veriler alınamadı',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadActivities('task-1');
    });

    test('refreshActivities updates activities on success', () async {
      mockRepo.mockActivities = [
        TodoItemActivityResponseDto(
          id: '1',
          userId: 'u1',
          userEmail: 'user@test.com',
          action: 'Updated',
          createdAt: DateTime.parse('2026-10-04T12:00:00Z'),
        ),
      ];

      await cubit.refreshActivities('task-1');

      expect(cubit.state.status, TaskActivitiesStatus.success);
      expect(cubit.state.activities.length, 1);
      expect(cubit.state.activities.first.id, '1');
    });

    test('refreshActivities emits error on failure', () async {
      mockRepo.shouldThrow = true;
      mockRepo.failure = const ServerFailure(message: 'Yenileme hatası');

      await cubit.refreshActivities('task-1');

      expect(cubit.state.status, TaskActivitiesStatus.error);
      expect(cubit.state.errorMessage, 'Yenileme hatası');
    });

    test('isClosed guard prevents crash when emit is called after close',
        () async {
      await cubit.close();

      // Should not throw StateError
      expect(
        () => cubit.emit(
          const TaskActivitiesState(status: TaskActivitiesStatus.loading),
        ),
        returnsNormally,
      );
    });
  });

  group('TaskActivities Widget Tests', () {
    testWidgets('TaskActivityItemTile renders title, user email, and details',
        (tester) async {
      final activity = TodoItemActivityResponseDto(
        id: '1',
        userId: 'u1',
        userEmail: 'alice@example.com',
        action: 'Created',
        details: 'Örnek görev oluşturuldu',
        createdAt: DateTime(2026, 10, 4, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskActivityItemTile(activity: activity),
          ),
        ),
      );

      expect(find.text('Görev Oluşturuldu'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.text('Örnek görev oluşturuldu'), findsOneWidget);
    });

    testWidgets(
        'TaskActivitiesSection displays empty message when no activities exist',
        (tester) async {
      final mockRepo = MockTaskActivitiesRepository();
      mockRepo.mockActivities = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepositoryProvider<TaskActivitiesRepository>.value(
              value: mockRepo,
              child: const TaskActivitiesSection(taskId: 'task-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Bu görev için henüz bir aktivite kaydı bulunmuyor.'),
        findsOneWidget,
      );
      expect(find.text('Aktivite Geçmişi (0)'), findsOneWidget);
    });

    testWidgets('TaskActivitiesSection renders activity list and count',
        (tester) async {
      final mockRepo = MockTaskActivitiesRepository();
      mockRepo.mockActivities = [
        TodoItemActivityResponseDto(
          id: '1',
          userId: 'u1',
          userEmail: 'bob@example.com',
          action: 'Completed',
          createdAt: DateTime(2026, 10, 4, 15, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepositoryProvider<TaskActivitiesRepository>.value(
              value: mockRepo,
              child: const TaskActivitiesSection(taskId: 'task-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aktivite Geçmişi (1)'), findsOneWidget);
      expect(find.text('Görev Tamamlandı'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
    });

    testWidgets(
        'TaskActivitiesSection displays error message and retry button on failure',
        (tester) async {
      final mockRepo = MockTaskActivitiesRepository();
      mockRepo.shouldThrow = true;
      mockRepo.failure = const ServerFailure(message: 'Sunucu yanıt vermedi');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepositoryProvider<TaskActivitiesRepository>.value(
              value: mockRepo,
              child: const TaskActivitiesSection(taskId: 'task-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sunucu yanıt vermedi'), findsOneWidget);
      expect(find.text('Tekrar Dene'), findsOneWidget);
    });
  });
}
