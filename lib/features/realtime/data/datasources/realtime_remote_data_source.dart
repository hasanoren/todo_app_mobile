import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/realtime_event.dart';

abstract class RealtimeRemoteDataSource {
  Stream<RealtimeEvent> get eventStream;
  Stream<bool> get isConnectedStream;
  bool get isConnected;
  Future<void> start();
  Future<void> stop();
}

class SignalRRemoteDataSourceImpl implements RealtimeRemoteDataSource {
  final SecureStorageService storageService;
  final String hubUrl;

  HubConnection? _hubConnection;
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  SignalRRemoteDataSourceImpl({
    required this.storageService,
    this.hubUrl = ApiConstants.signalRHub,
  });

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  Stream<bool> get isConnectedStream => _connectionStateController.stream;

  @override
  bool get isConnected =>
      _hubConnection?.state == HubConnectionState.Connected;

  @override
  Future<void> start() async {
    if (isConnected) return;

    try {
      if (_hubConnection == null) {
        _hubConnection = HubConnectionBuilder()
            .withUrl(
              hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async {
                  final token = await storageService.getAccessToken();
                  return token ?? '';
                },
              ),
            )
            .withAutomaticReconnect()
            .build();

        _registerHandlers();
      }

      await _hubConnection!.start();
      _connectionStateController.add(true);
    } catch (_) {
      _connectionStateController.add(false);
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection!.stop();
      }
    } catch (_) {
      // Ignored
    } finally {
      _connectionStateController.add(false);
    }
  }

  void _registerHandlers() {
    final hub = _hubConnection;
    if (hub == null) return;

    hub.onclose(({error}) {
      _connectionStateController.add(false);
    });

    hub.onreconnecting(({error}) {
      _connectionStateController.add(false);
    });

    hub.onreconnected(({connectionId}) {
      _connectionStateController.add(true);
    });

    // 1. ReceiveNotification(title, message)
    hub.on('ReceiveNotification', (args) {
      if (args != null && args.isNotEmpty) {
        final title = args.isNotEmpty ? args[0]?.toString() ?? '' : '';
        final message = args.length > 1 ? args[1]?.toString() ?? '' : '';
        _eventController.add(
          ReceiveNotificationEvent(title: title, message: message),
        );
      }
    });

    // 2. TaskShared(taskId, taskTitle)
    hub.on('TaskShared', (args) {
      if (args != null && args.isNotEmpty) {
        final taskId = args.isNotEmpty ? args[0]?.toString() ?? '' : '';
        final taskTitle = args.length > 1 ? args[1]?.toString() ?? '' : '';
        _eventController.add(
          TaskSharedEvent(taskId: taskId, taskTitle: taskTitle),
        );
      }
    });

    // 3. TaskUpdated(taskId)
    hub.on('TaskUpdated', (args) {
      if (args != null && args.isNotEmpty) {
        final taskId = args.isNotEmpty ? args[0]?.toString() ?? '' : '';
        _eventController.add(TaskUpdatedEvent(taskId: taskId));
      }
    });

    // 4. TransferRequested(requestId, taskTitle)
    hub.on('TransferRequested', (args) {
      if (args != null && args.isNotEmpty) {
        final requestId = args.isNotEmpty ? args[0]?.toString() ?? '' : '';
        final taskTitle = args.length > 1 ? args[1]?.toString() ?? '' : '';
        _eventController.add(
          TransferRequestedEvent(requestId: requestId, taskTitle: taskTitle),
        );
      }
    });
  }

  void dispose() {
    _eventController.close();
    _connectionStateController.close();
  }
}

