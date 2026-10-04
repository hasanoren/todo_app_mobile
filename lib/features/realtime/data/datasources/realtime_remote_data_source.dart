import 'dart:async';
import 'package:flutter/foundation.dart';
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

  bool _isConnecting = false;

  @override
  Stream<RealtimeEvent> get eventStream => _eventController.stream;

  @override
  Stream<bool> get isConnectedStream => _connectionStateController.stream;

  @override
  bool get isConnected =>
      _hubConnection?.state == HubConnectionState.Connected;

  @override
  Future<void> start() async {
    if (_isConnecting ||
        _hubConnection?.state == HubConnectionState.Connected ||
        _hubConnection?.state == HubConnectionState.Connecting) {
      debugPrint('[SignalR] Already connecting or connected. Ignoring duplicate start call.');
      return;
    }

    _isConnecting = true;
    try {
      if (_hubConnection != null) {
        try {
          await _hubConnection!.stop();
        } catch (_) {}
        _hubConnection = null;
      }

      final token = await storageService.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[SignalR] No access token found. Waiting for login.');
        return;
      }

      debugPrint('[SignalR] Connecting to $hubUrl (Token length: ${token.length})');

      final uri = Uri.parse(hubUrl);
      final hubUrlWithToken = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'access_token': token,
        },
      ).toString();

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrlWithToken,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              requestTimeout: 15000,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _registerHandlers();

      await _hubConnection!.start();
      debugPrint(
        '[SignalR] CONNECTED SUCCESSFULLY! State: ${_hubConnection?.state}',
      );
      _connectionStateController.add(true);
    } catch (e, stack) {
      debugPrint('[SignalR] FAILED TO CONNECT: $e');
      debugPrint('[SignalR] Stack trace: $stack');
      _connectionStateController.add(false);
    } finally {
      _isConnecting = false;
    }
  }

  @override
  Future<void> stop() async {
    _isConnecting = false;
    try {
      if (_hubConnection != null) {
        debugPrint('[SignalR] Stopping connection...');
        await _hubConnection!.stop();
        _hubConnection = null;
      }
    } catch (e) {
      debugPrint('[SignalR] Error stopping: $e');
    } finally {
      _connectionStateController.add(false);
    }
  }

  void _registerHandlers() {
    final hub = _hubConnection;
    if (hub == null) return;

    hub.onclose(({error}) {
      debugPrint('[SignalR] Connection closed. Error: $error');
      _connectionStateController.add(false);
    });

    hub.onreconnecting(({error}) {
      debugPrint('[SignalR] Connection reconnecting... Error: $error');
      _connectionStateController.add(false);
    });

    hub.onreconnected(({connectionId}) {
      debugPrint('[SignalR] Connection reconnected! Connection ID: $connectionId');
      _connectionStateController.add(true);
    });

    // 1. ReceiveNotification
    void handleNotification(List<dynamic>? args) {
      debugPrint('[SignalR] Event received: ReceiveNotification $args');
      if (args != null && args.isNotEmpty) {
        String title = '';
        String message = '';
        if (args[0] is Map) {
          final map = args[0] as Map;
          title = map['title']?.toString() ?? 'Bildirim';
          message = map['message']?.toString() ?? '';
        } else {
          title = args[0]?.toString() ?? 'Bildirim';
          message = args.length > 1 ? args[1]?.toString() ?? '' : '';
        }
        _eventController.add(
          ReceiveNotificationEvent(title: title, message: message),
        );
      }
    }

    hub.on('ReceiveNotification', handleNotification);
    hub.on('Notification', handleNotification);

    // 2. TaskShared
    void handleTaskShared(List<dynamic>? args) {
      debugPrint('[SignalR] Event received: TaskShared $args');
      if (args != null && args.isNotEmpty) {
        String taskId = '';
        String taskTitle = '';
        if (args[0] is Map) {
          final map = args[0] as Map;
          taskId = map['taskId']?.toString() ?? map['id']?.toString() ?? '';
          taskTitle =
              map['taskTitle']?.toString() ?? map['title']?.toString() ?? '';
        } else {
          taskId = args[0]?.toString() ?? '';
          taskTitle = args.length > 1 ? args[1]?.toString() ?? '' : '';
        }
        _eventController.add(
          TaskSharedEvent(taskId: taskId, taskTitle: taskTitle),
        );
      }
    }

    hub.on('TaskShared', handleTaskShared);

    // 3. TaskUpdated
    void handleTaskUpdated(List<dynamic>? args) {
      debugPrint('[SignalR] Event received: TaskUpdated $args');
      if (args != null && args.isNotEmpty) {
        String taskId = '';
        if (args[0] is Map) {
          final map = args[0] as Map;
          taskId = map['taskId']?.toString() ?? map['id']?.toString() ?? '';
        } else {
          taskId = args[0]?.toString() ?? '';
        }
        _eventController.add(TaskUpdatedEvent(taskId: taskId));
      }
    }

    hub.on('TaskUpdated', handleTaskUpdated);

    // 4. TransferRequested
    void handleTransferRequested(List<dynamic>? args) {
      debugPrint('[SignalR] Event received: TransferRequested $args');
      if (args != null && args.isNotEmpty) {
        String requestId = '';
        String taskTitle = '';
        if (args[0] is Map) {
          final map = args[0] as Map;
          requestId =
              map['id']?.toString() ?? map['requestId']?.toString() ?? '';
          taskTitle =
              map['taskTitle']?.toString() ?? map['title']?.toString() ?? '';
        } else {
          requestId = args[0]?.toString() ?? '';
          taskTitle = args.length > 1 ? args[1]?.toString() ?? '' : '';
        }
        _eventController.add(
          TransferRequestedEvent(requestId: requestId, taskTitle: taskTitle),
        );
      }
    }

    hub.on('TransferRequested', handleTransferRequested);
    hub.on('TransferRequestCreated', handleTransferRequested);
    hub.on('TransferRequestReceived', handleTransferRequested);

    // 5. Additional transfer lifecycle events (Accepted / Rejected / Cancelled)
    void handleTransferStatusChanged(List<dynamic>? args) {
      debugPrint('[SignalR] Event received transfer status change: $args');
      String msg = 'Devir isteği durumu güncellendi.';
      if (args != null && args.isNotEmpty) {
        if (args[0] is Map) {
          msg = args[0]['message']?.toString() ??
              args[0]['taskTitle']?.toString() ??
              msg;
        } else {
          msg = args[0]?.toString() ?? msg;
        }
      }
      _eventController.add(
        ReceiveNotificationEvent(
          title: 'Sahiplik Devri Bildirimi',
          message: msg,
        ),
      );
    }

    hub.on('TransferAccepted', handleTransferStatusChanged);
    hub.on('TransferRequestAccepted', handleTransferStatusChanged);
    hub.on('TransferRejected', handleTransferStatusChanged);
    hub.on('TransferRequestRejected', handleTransferStatusChanged);
    hub.on('TransferCancelled', handleTransferStatusChanged);
    hub.on('TransferRequestCancelled', handleTransferStatusChanged);

    // 6. Additional task lifecycle events
    void handleTaskLifeCycle(List<dynamic>? args) {
      debugPrint('[SignalR] Event received TaskLifeCycle: $args');
      String taskId = '';
      if (args != null && args.isNotEmpty) {
        if (args[0] is Map) {
          taskId = args[0]['taskId']?.toString() ??
              args[0]['id']?.toString() ??
              '';
        } else {
          taskId = args[0]?.toString() ?? '';
        }
      }
      _eventController.add(TaskUpdatedEvent(taskId: taskId));
    }

    hub.on('TaskDeleted', handleTaskLifeCycle);
    hub.on('TaskCompleted', handleTaskLifeCycle);
    hub.on('TaskCreated', handleTaskLifeCycle);
  }

  void dispose() {
    _eventController.close();
    _connectionStateController.close();
  }
}

