import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip injecting token for public endpoints (like register, login, login-2fa, refresh)
    // Though technically backend rejects if absent on protected, doing it here is cleaner.
    final publicPaths = [
      '/api/Auth/register',
      '/api/Auth/login',
      '/api/Auth/login-2fa',
      '/api/Auth/refresh',
    ];

    if (!publicPaths.any((path) => options.path.contains(path))) {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return handler.next(options);
  }
}
