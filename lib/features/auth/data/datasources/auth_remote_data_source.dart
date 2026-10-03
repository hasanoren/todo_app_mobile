import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/auth_response_dto.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/login_2fa_request.dart';
import '../models/refresh_token_request.dart';
import '../models/logout_request.dart';
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';
import '../models/auth_message_response_dto.dart';
import '../models/two_factor_enable_response_dto.dart';
import '../models/two_factor_verify_request.dart';
import '../models/two_factor_disable_request.dart';
import '../models/user_profile_response_dto.dart';
import '../models/change_password_request.dart';
import '../models/delete_account_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> register(RegisterRequest request);
  Future<AuthResponseDto> login(LoginRequest request);
  Future<AuthResponseDto> login2Fa(Login2FaRequest request);
  Future<AuthResponseDto> refresh(RefreshTokenRequest request);
  Future<void> logout(LogoutRequest request);
  Future<AuthMessageResponseDto> forgotPassword(ForgotPasswordRequest request);
  Future<AuthMessageResponseDto> resetPassword(ResetPasswordRequest request);
  Future<UserProfileResponseDto> getProfile();
  Future<TwoFactorEnableResponseDto> enable2fa();
  Future<AuthMessageResponseDto> verify2fa(TwoFactorVerifyRequest request);
  Future<AuthMessageResponseDto> disable2fa(TwoFactorDisableRequest request);
  Future<void> changePassword(ChangePasswordRequest request);
  Future<void> deleteAccount(DeleteAccountRequest request);
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

  @override
  Future<AuthMessageResponseDto> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: request.toJson(),
      );

      return AuthMessageResponseDto.fromJson(response.data);
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
  Future<AuthMessageResponseDto> resetPassword(
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );

      return AuthMessageResponseDto.fromJson(response.data);
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
  Future<UserProfileResponseDto> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.userMe);
      return UserProfileResponseDto.fromJson(response.data);
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
  Future<TwoFactorEnableResponseDto> enable2fa() async {
    try {
      final response = await _dio.post(ApiConstants.enable2fa);
      return TwoFactorEnableResponseDto.fromJson(response.data);
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
  Future<AuthMessageResponseDto> verify2fa(TwoFactorVerifyRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.verify2fa,
        data: request.toJson(),
      );
      return AuthMessageResponseDto.fromJson(response.data);
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
  Future<AuthMessageResponseDto> disable2fa(TwoFactorDisableRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.disable2fa,
        data: request.toJson(),
      );
      return AuthMessageResponseDto.fromJson(response.data);
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
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _dio.put(
        ApiConstants.changePassword,
        data: request.toJson(),
      );
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
  Future<void> deleteAccount(DeleteAccountRequest request) async {
    try {
      await _dio.delete(
        ApiConstants.userMe,
        data: request.toJson(),
      );
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
}
