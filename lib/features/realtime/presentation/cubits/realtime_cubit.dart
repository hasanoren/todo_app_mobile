import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/models/realtime_event.dart';
import '../../domain/repositories/realtime_repository.dart';
import 'realtime_state.dart';

class RealtimeCubit extends Cubit<RealtimeState> {
  final RealtimeRepository repository;
  final AuthBloc? authBloc;

  StreamSubscription<RealtimeEvent>? _eventSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  RealtimeCubit({
    required this.repository,
    this.authBloc,
  }) : super(RealtimeState(isConnected: repository.isConnected)) {
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

    if (authBloc != null) {
      _authSubscription = authBloc!.stream.listen((authState) {
        if (authState is Authenticated) {
          startConnection();
        } else if (authState is Unauthenticated) {
          stopConnection();
        }
      });

      if (authBloc!.state is Authenticated) {
        startConnection();
      }
    }
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
    _authSubscription?.cancel();
    return super.close();
  }
}

