import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  late final Dio _dio;
  late final Dio _refreshDio;

  Dio get dio => _dio;

  DioClient(SecureStorageService secureStorage, {Function()? onRefreshFailed}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        contentType: 'application/json',
      ),
    );

    // Secondary dio for refresh to avoid interceptor recursion
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      TokenRefreshInterceptor(
        dio: _dio,
        refreshDio: _refreshDio,
        secureStorage: secureStorage,
        onRefreshFailed: onRefreshFailed,
      ),
      LogInterceptor(responseBody: true, requestBody: true), // For debugging
    ]);
  }
}
