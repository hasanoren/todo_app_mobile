import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/features/realtime/data/datasources/realtime_remote_data_source.dart';
import 'package:todo_app_mobile/features/realtime/data/repositories/realtime_repository_impl.dart';
import 'package:todo_app_mobile/features/realtime/domain/models/realtime_event.dart';
import 'package:todo_app_mobile/features/realtime/domain/repositories/realtime_repository.dart';
import 'package:todo_app_mobile/features/realtime/presentation/cubits/realtime_cubit.dart';
import 'package:todo_app_mobile/features/realtime/presentation/cubits/realtime_state.dart';
import 'package:todo_app_mobile/features/realtime/presentation/widgets/realtime_notification_listener.dart';

class MockRealtimeRemoteDataSource implements RealtimeRemoteDataSource {
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  final _connController = StreamController<bool>.broadcast();
  bool mockIsConnected = false;
  int startCallCount = 0;
  int stopCallCount = 0;

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  Stream<bool> get isConnectedStream => _connController.stream;

  @override
  bool get isConnected => mockIsConnected;

  @override
  Future<void> start() async {
    startCallCount++;
    mockIsConnected = true;
    _connController.add(true);
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    mockIsConnected = false;
    _connController.add(false);
  }

  void emitEvent(RealtimeEvent event) {
    _eventController.add(event);
  }

  void emitConnection(bool connected) {
    mockIsConnected = connected;
    _connController.add(connected);
  }

  void dispose() {
    _eventController.close();
    _connController.close();
  }
}

class MockRealtimeRepository implements RealtimeRepository {
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  final _connController = StreamController<bool>.broadcast();
  bool mockIsConnected = false;
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  Stream<RealtimeEvent> get events => _eventController.stream;

  @override
  Stream<bool> get isConnectedStream => _connController.stream;

  @override
  bool get isConnected => mockIsConnected;

  @override
  Future<void> connect() async {
    connectCalls++;
    mockIsConnected = true;
    _connController.add(true);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    mockIsConnected = false;
    _connController.add(false);
  }

  void emitEvent(RealtimeEvent event) {
    _eventController.add(event);
  }

  void emitConnection(bool connected) {
    mockIsConnected = connected;
    _connController.add(connected);
  }

  void dispose() {
    _eventController.close();
    _connController.close();
  }
}

void main() {
  group('RealtimeEvent Model Tests', () {
    test('ReceiveNotificationEvent equality and props', () {
      const e1 = ReceiveNotificationEvent(title: 'T1', message: 'M1');
      const e2 = ReceiveNotificationEvent(title: 'T1', message: 'M1');
      expect(e1, equals(e2));
      expect(e1.props, ['T1', 'M1']);
    });

    test('TaskSharedEvent equality and props', () {
      const e1 = TaskSharedEvent(taskId: 'task-1', taskTitle: 'Title 1');
      const e2 = TaskSharedEvent(taskId: 'task-1', taskTitle: 'Title 1');
      expect(e1, equals(e2));
      expect(e1.props, ['task-1', 'Title 1']);
    });

    test('TaskUpdatedEvent equality and props', () {
      const e1 = TaskUpdatedEvent(taskId: 'task-1');
      const e2 = TaskUpdatedEvent(taskId: 'task-1');
      expect(e1, equals(e2));
      expect(e1.props, ['task-1']);
    });

    test('TransferRequestedEvent equality and props', () {
      const e1 =
          TransferRequestedEvent(requestId: 'req-1', taskTitle: 'Task 1');
      const e2 =
          TransferRequestedEvent(requestId: 'req-1', taskTitle: 'Task 1');
      expect(e1, equals(e2));
      expect(e1.props, ['req-1', 'Task 1']);
    });
  });

  group('RealtimeRepositoryImpl Tests', () {
    late MockRealtimeRemoteDataSource mockDS;
    late RealtimeRepositoryImpl repo;

    setUp(() {
      mockDS = MockRealtimeRemoteDataSource();
      repo = RealtimeRepositoryImpl(remoteDataSource: mockDS);
    });

    tearDown(() {
      mockDS.dispose();
    });

    test('connect and disconnect call remote data source start and stop',
        () async {
      await repo.connect();
      expect(mockDS.startCallCount, 1);
      expect(repo.isConnected, true);

      await repo.disconnect();
      expect(mockDS.stopCallCount, 1);
      expect(repo.isConnected, false);
    });

    test('events stream forwards events from remote data source', () async {
      const event = TaskUpdatedEvent(taskId: 'task-99');
      final expectation = expectLater(repo.events, emits(event));
      mockDS.emitEvent(event);
      await expectation;
    });
  });

  group('RealtimeCubit Tests', () {
    late MockRealtimeRepository mockRepo;
    late RealtimeCubit cubit;

    setUp(() {
      mockRepo = MockRealtimeRepository();
      cubit = RealtimeCubit(repository: mockRepo);
    });

    tearDown(() {
      cubit.close();
      mockRepo.dispose();
    });

    test('initial state has false connection and null event', () {
      expect(cubit.state.isConnected, false);
      expect(cubit.state.lastEvent, isNull);
    });

    test('emits isConnected true when repository connection stream fires true',
        () async {
      mockRepo.emitConnection(true);
      await pumpEventQueue();
      expect(cubit.state.isConnected, true);
    });

    test('emits event and timestamp when repository events stream fires',
        () async {
      const event =
          ReceiveNotificationEvent(title: 'Sistem', message: 'Hoş geldiniz');
      mockRepo.emitEvent(event);
      await pumpEventQueue();
      expect(cubit.state.lastEvent, equals(event));
      expect(cubit.state.lastEventTime, isNotNull);
    });

    test('startConnection calls repo connect', () async {
      await cubit.startConnection();
      expect(mockRepo.connectCalls, 1);
    });

    test('stopConnection calls repo disconnect', () async {
      await cubit.stopConnection();
      expect(mockRepo.disconnectCalls, 1);
    });

    test('isClosed guard prevents crash when emit is called after close',
        () async {
      await cubit.close();
      expect(
        () => cubit.emit(const RealtimeState(isConnected: true)),
        returnsNormally,
      );
    });
  });

  group('RealtimeNotificationListener Widget Tests', () {
    testWidgets('triggers callback on event without throwing', (tester) async {
      final mockRepo = MockRealtimeRepository();
      final cubit = RealtimeCubit(repository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(
              body: RealtimeNotificationListener(
                child: Text('Home Screen'),
              ),
            ),
          ),
        ),
      );

      mockRepo.emitEvent(
        const ReceiveNotificationEvent(
          title: 'Yeni Duyuru',
          message: 'Sistem bakımda olacaktır.',
        ),
      );

      await tester.pump();
      expect(find.text('Home Screen'), findsOneWidget);

      await cubit.close();
      mockRepo.dispose();
    });
  });
}

