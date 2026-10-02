// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';

import 'dart:async';

import '../../storage/secure_storage_service.dart';
import '../../constants/api_constants.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final Dio _refreshDio;
  final SecureStorageService _secureStorage;
  final Function()? onRefreshFailed;

  TokenRefreshInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required SecureStorageService secureStorage,
    this.onRefreshFailed,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _secureStorage = secureStorage;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        // No refresh token available, session is definitely expired
        return handler.next(err);
      }

      try {
        final response = await _refreshDio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final data = response.data;

          await _secureStorage.saveAuthTokens(
            accessToken: data['token'],
            refreshToken: data['refreshToken'],
            userId: data['userId'] ?? '',
            email: data['email'] ?? '',
            expiresAt: DateTime.now().add(const Duration(minutes: 55)),
          );

          // Retry the original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${data['token']}';

          final cloneReq = await _dio.fetch(opts);
          return handler.resolve(cloneReq);
        }
      } catch (e) {
        // Refresh failed (e.g. revoked token). Wipe data.
        await _secureStorage.clearAuthData();
        onRefreshFailed?.call();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
