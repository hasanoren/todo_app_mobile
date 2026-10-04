import 'package:equatable/equatable.dart';

import '../../domain/models/realtime_event.dart';

class RealtimeState extends Equatable {
  final bool isConnected;
  final RealtimeEvent? lastEvent;
  final DateTime? lastEventTime;

  const RealtimeState({
    this.isConnected = false,
    this.lastEvent,
    this.lastEventTime,
  });

  RealtimeState copyWith({
    bool? isConnected,
    RealtimeEvent? lastEvent,
    DateTime? lastEventTime,
  }) {
    return RealtimeState(
      isConnected: isConnected ?? this.isConnected,
      lastEvent: lastEvent ?? this.lastEvent,
      lastEventTime: lastEventTime ?? this.lastEventTime,
    );
  }

  @override
  List<Object?> get props => [isConnected, lastEvent, lastEventTime];
}

