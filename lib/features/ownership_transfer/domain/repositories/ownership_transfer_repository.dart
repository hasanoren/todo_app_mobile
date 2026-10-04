import '../../data/models/create_transfer_request_dto.dart';
import '../../data/models/transfer_action_response_dto.dart';
import '../../data/models/transfer_request_response_dto.dart';

abstract class OwnershipTransferRepository {
  Future<TransferRequestResponseDto> createTransferRequest(
    String taskId,
    CreateTransferRequestDto request,
  );
  Future<List<TransferRequestResponseDto>> getPendingTransferRequests();
  Future<TransferActionResponseDto> acceptTransferRequest(String requestId);
  Future<TransferActionResponseDto> rejectTransferRequest(String requestId);
  Future<TransferActionResponseDto> cancelTransferRequest(String requestId);
}

