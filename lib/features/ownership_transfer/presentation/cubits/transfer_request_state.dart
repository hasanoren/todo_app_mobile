import 'package:equatable/equatable.dart';

import '../../data/models/transfer_request_response_dto.dart';

enum TransferRequestStatus {
  initial,
  loading,
  success,
  error,
}

class TransferRequestState extends Equatable {
  final TransferRequestStatus status;
  final TransferRequestResponseDto? createdRequest;
  final String? errorMessage;
  final String? successMessage;

  const TransferRequestState({
    this.status = TransferRequestStatus.initial,
    this.createdRequest,
    this.errorMessage,
    this.successMessage,
  });

  TransferRequestState copyWith({
    TransferRequestStatus? status,
    TransferRequestResponseDto? createdRequest,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return TransferRequestState(
      status: status ?? this.status,
      createdRequest: createdRequest ?? this.createdRequest,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, createdRequest, errorMessage, successMessage];
}

