import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/ownership_transfer_repository.dart';
import '../datasources/ownership_transfer_remote_data_source.dart';
import '../models/create_transfer_request_dto.dart';
import '../models/transfer_action_response_dto.dart';
import '../models/transfer_request_response_dto.dart';

class OwnershipTransferRepositoryImpl implements OwnershipTransferRepository {
  final OwnershipTransferRemoteDataSource remoteDataSource;

  OwnershipTransferRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TransferRequestResponseDto> createTransferRequest(
    String taskId,
    CreateTransferRequestDto request,
  ) async {
    try {
      return await remoteDataSource.createTransferRequest(taskId, request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Devir isteği oluşturulurken bir hata oluştu.',
      );
    }
  }

  @override
  Future<List<TransferRequestResponseDto>> getPendingTransferRequests() async {
    try {
      return await remoteDataSource.getPendingTransferRequests();
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Bekleyen devir istekleri yüklenirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TransferActionResponseDto> acceptTransferRequest(
    String requestId,
  ) async {
    try {
      return await remoteDataSource.acceptTransferRequest(requestId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Devir isteği kabul edilirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TransferActionResponseDto> rejectTransferRequest(
    String requestId,
  ) async {
    try {
      return await remoteDataSource.rejectTransferRequest(requestId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Devir isteği reddedilirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TransferActionResponseDto> cancelTransferRequest(
    String requestId,
  ) async {
    try {
      return await remoteDataSource.cancelTransferRequest(requestId);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Devir isteği iptal edilirken bir hata oluştu.',
      );
    }
  }
}

