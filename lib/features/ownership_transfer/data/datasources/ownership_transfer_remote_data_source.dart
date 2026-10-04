import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/create_transfer_request_dto.dart';
import '../models/transfer_action_response_dto.dart';
import '../models/transfer_request_response_dto.dart';
import '../models/transfer_requests_collection_response_dto.dart';

abstract class OwnershipTransferRemoteDataSource {
  Future<TransferRequestResponseDto> createTransferRequest(
    String taskId,
    CreateTransferRequestDto request,
  );
  Future<List<TransferRequestResponseDto>> getPendingTransferRequests();
  Future<TransferActionResponseDto> acceptTransferRequest(String requestId);
  Future<TransferActionResponseDto> rejectTransferRequest(String requestId);
  Future<TransferActionResponseDto> cancelTransferRequest(String requestId);
}

class OwnershipTransferRemoteDataSourceImpl
    implements OwnershipTransferRemoteDataSource {
  final Dio dio;

  OwnershipTransferRemoteDataSourceImpl({required this.dio});

  @override
  Future<TransferRequestResponseDto> createTransferRequest(
    String taskId,
    CreateTransferRequestDto request,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.taskTransferRequests(taskId),
        data: request.toJson(),
      );
      return TransferRequestResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<List<TransferRequestResponseDto>> getPendingTransferRequests() async {
    try {
      final response = await dio.get(ApiConstants.transferRequestsPending);
      final parsed =
          TransferRequestsCollectionResponseDto.fromJson(response.data);
      return parsed.items;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TransferActionResponseDto> acceptTransferRequest(
    String requestId,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.transferRequestAccept(requestId),
      );
      if (response.data is Map<String, dynamic>) {
        return TransferActionResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const TransferActionResponseDto(
        message: 'Devir isteği kabul edildi ve sahiplik devredildi.',
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TransferActionResponseDto> rejectTransferRequest(
    String requestId,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.transferRequestReject(requestId),
      );
      if (response.data is Map<String, dynamic>) {
        return TransferActionResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const TransferActionResponseDto(
        message: 'Devir isteği reddedildi.',
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<TransferActionResponseDto> cancelTransferRequest(
    String requestId,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.transferRequestCancel(requestId),
      );
      if (response.data is Map<String, dynamic>) {
        return TransferActionResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return const TransferActionResponseDto(
        message: 'Devir isteği iptal edildi.',
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.response != null) {
      throw ApiException.fromJson(
        e.response!.data is Map<String, dynamic>
            ? e.response!.data as Map<String, dynamic>
            : {},
        e.response!.statusCode ?? 500,
      );
    } else {
      throw ApiException(
        statusCode: 500,
        title: 'Network Error',
        detail: e.message ?? 'Bir ağ hatası oluştu.',
      );
    }
  }
}

