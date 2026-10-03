import 'package:equatable/equatable.dart';

import '../../data/models/subtask_response_dto.dart';

enum SubtasksStatus { initial, loading, success, error }

class SubtasksState extends Equatable {
  final SubtasksStatus status;
  final List<SubtaskResponseDto> items;
  final bool isAdding;
  final String? togglingId;
  final String? errorMessage;

  const SubtasksState({
    this.status = SubtasksStatus.initial,
    this.items = const [],
    this.isAdding = false,
    this.togglingId,
    this.errorMessage,
  });

  int get totalCount => items.length;
  int get completedCount => items.where((s) => s.isCompleted).length;
  double get progressRatio =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount);

  SubtasksState copyWith({
    SubtasksStatus? status,
    List<SubtaskResponseDto>? items,
    bool? isAdding,
    String? togglingId,
    bool clearTogglingId = false,
    String? errorMessage,
  }) {
    return SubtasksState(
      status: status ?? this.status,
      items: items ?? this.items,
      isAdding: isAdding ?? this.isAdding,
      togglingId: clearTogglingId ? null : (togglingId ?? this.togglingId),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    isAdding,
    togglingId,
    errorMessage,
  ];
}
