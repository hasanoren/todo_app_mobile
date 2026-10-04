import '../../domain/models/realtime_event.dart';
import '../../domain/repositories/realtime_repository.dart';
import '../datasources/realtime_remote_data_source.dart';

class RealtimeRepositoryImpl implements RealtimeRepository {
  final RealtimeRemoteDataSource remoteDataSource;

  RealtimeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<RealtimeEvent> get events => remoteDataSource.eventStream;

  @override
  Stream<bool> get isConnectedStream => remoteDataSource.isConnectedStream;

  @override
  bool get isConnected => remoteDataSource.isConnected;

  @override
  Future<void> connect() async {
    await remoteDataSource.start();
  }

  @override
  Future<void> disconnect() async {
    await remoteDataSource.stop();
  }
}

