import '../models/realtime_event.dart';

abstract class RealtimeRepository {
  Stream<RealtimeEvent> get events;
  Stream<bool> get isConnectedStream;
  bool get isConnected;
  Future<void> connect();
  Future<void> disconnect();
}

