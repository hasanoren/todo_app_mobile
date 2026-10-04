import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/realtime_event.dart';
import '../../domain/repositories/realtime_repository.dart';
import 'realtime_state.dart';

class RealtimeCubit extends Cubit<RealtimeState> {
  final RealtimeRepository repository;

  StreamSubscription<RealtimeEvent>? _eventSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  RealtimeCubit({required this.repository})
      : super(RealtimeState(isConnected: repository.isConnected)) {
    _initSubscriptions();
  }

  void _initSubscriptions() {
    _connectionSubscription = repository.isConnectedStream.listen((connected) {
      emit(state.copyWith(isConnected: connected));
    });

    _eventSubscription = repository.events.listen((event) {
      emit(
        state.copyWith(
          lastEvent: event,
          lastEventTime: DateTime.now(),
        ),
      );
    });
  }

  @override
  void emit(RealtimeState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> startConnection() async {
    await repository.connect();
  }

  Future<void> stopConnection() async {
    await repository.disconnect();
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}

