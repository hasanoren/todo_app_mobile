import 'package:equatable/equatable.dart';

import '../../data/models/transfer_request_response_dto.dart';

enum PendingTransfersStatus {
  initial,
  loading,
  success,
  actionInProgress,
  error,
}

class PendingTransfersState extends Equatable {
  final PendingTransfersStatus status;
  final List<TransferRequestResponseDto> items;
  final String? errorMessage;
  final String? successMessage;

  const PendingTransfersState({
    this.status = PendingTransfersStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.successMessage,
  });

  int get pendingCount => items.length;

  PendingTransfersState copyWith({
    PendingTransfersStatus? status,
    List<TransferRequestResponseDto>? items,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return PendingTransfersState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, successMessage];
}

