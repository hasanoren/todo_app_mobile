import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/auth_response_dto.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/login_2fa_request.dart';
import '../models/refresh_token_request.dart';
import '../models/logout_request.dart';

// Note: Other models will be imported as needed in future tasks

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> register(RegisterRequest request);
  Future<AuthResponseDto> login(LoginRequest request);
  Future<AuthResponseDto> login2Fa(Login2FaRequest request);
  Future<AuthResponseDto> refresh(RefreshTokenRequest request);
  Future<void> logout(LogoutRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseDto> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException.fromJson(
          e.response!.data is Map<String, dynamic> ? e.response!.data : {},
          e.response!.statusCode ?? 500,
        );
      } else {
        throw ApiException(
          statusCode: 500,
          title: 'Network Error',
          detail: e.message ?? 'Unknown error occurred.',
        );
      }
    }
  }

  @override
  Future<AuthResponseDto> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException.fromJson(
          e.response!.data is Map<String, dynamic> ? e.response!.data : {},
          e.response!.statusCode ?? 500,
        );
      } else {
        throw ApiException(
          statusCode: 500,
          title: 'Network Error',
          detail: e.message ?? 'Unknown error occurred.',
        );
      }
    }
  }

  @override
  Future<AuthResponseDto> login2Fa(Login2FaRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login2fa,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException.fromJson(
          e.response!.data is Map<String, dynamic> ? e.response!.data : {},
          e.response!.statusCode ?? 500,
        );
      } else {
        throw ApiException(
          statusCode: 500,
          title: 'Network Error',
          detail: e.message ?? 'Unknown error occurred.',
        );
      }
    }
  }

  @override
  Future<AuthResponseDto> refresh(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.refresh,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException.fromJson(
          e.response!.data is Map<String, dynamic> ? e.response!.data : {},
          e.response!.statusCode ?? 500,
        );
      } else {
        throw ApiException(
          statusCode: 500,
          title: 'Network Error',
          detail: e.message ?? 'Unknown error occurred.',
        );
      }
    }
  }

  @override
  Future<void> logout(LogoutRequest request) async {
    try {
      await _dio.post(ApiConstants.logout, data: request.toJson());
    } on DioException catch (e) {
      // Logout might fail if token is already expired, we generally ignore this
      // but we can throw if we want strict handling.
      if (e.response != null) {
        throw ApiException.fromJson(
          e.response!.data is Map<String, dynamic> ? e.response!.data : {},
          e.response!.statusCode ?? 500,
        );
      } else {
        throw ApiException(
          statusCode: 500,
          title: 'Network Error',
          detail: e.message ?? 'Unknown error occurred.',
        );
      }
    }
  }
}
