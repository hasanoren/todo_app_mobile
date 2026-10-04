import 'dart:convert';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/ownership_transfer_repository.dart';
import '../datasources/ownership_transfer_remote_data_source.dart';
import '../models/create_transfer_request_dto.dart';
import '../models/transfer_action_response_dto.dart';
import '../models/transfer_request_response_dto.dart';

class OwnershipTransferRepositoryImpl implements OwnershipTransferRepository {
  final OwnershipTransferRemoteDataSource remoteDataSource;
  final SecureStorageService? storage;
  final Map<String, TransferRequestResponseDto> _memoryCache = {};

  OwnershipTransferRepositoryImpl({
    required this.remoteDataSource,
    this.storage,
  });

  @override
  Future<TransferRequestResponseDto> createTransferRequest(
    String taskId,
    CreateTransferRequestDto request,
  ) async {
    try {
      final result =
          await remoteDataSource.createTransferRequest(taskId, request);
      await saveActiveOutgoingTransferRequest(result);
      return result;
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
      final response = await remoteDataSource.cancelTransferRequest(requestId);
      _memoryCache.removeWhere((_, req) => req.id == requestId);
      return response;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (_) {
      throw const NetworkFailure(
        message: 'Devir isteği iptal edilirken bir hata oluştu.',
      );
    }
  }

  @override
  Future<TransferRequestResponseDto?> getActiveOutgoingTransferRequest(
    String taskId,
  ) async {
    if (_memoryCache.containsKey(taskId)) {
      return _memoryCache[taskId];
    }
    if (storage != null) {
      final jsonStr = await storage!.read('active_transfer_$taskId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          final parsed = TransferRequestResponseDto.fromJson(data);
          _memoryCache[taskId] = parsed;
          return parsed;
        } catch (_) {}
      }
    }
    return null;
  }

  @override
  Future<void> saveActiveOutgoingTransferRequest(
    TransferRequestResponseDto request,
  ) async {
    _memoryCache[request.taskId] = request;
    if (storage != null) {
      await storage!.write(
        'active_transfer_${request.taskId}',
        jsonEncode(request.toJson()),
      );
    }
  }

  @override
  Future<void> clearActiveOutgoingTransferRequest(String taskId) async {
    _memoryCache.remove(taskId);
    if (storage != null) {
      await storage!.delete('active_transfer_$taskId');
    }
  }
}

