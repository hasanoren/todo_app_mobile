import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ?? const FlutterSecureStorage(aOptions: AndroidOptions());

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Helper methods
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required DateTime expiresAt,
  }) async {
    await write(StorageKeys.authAccessToken, accessToken);
    await write(StorageKeys.authRefreshToken, refreshToken);
    await write(StorageKeys.authUserId, userId);
    await write(StorageKeys.authEmail, email);
    await write(StorageKeys.authTokenExpiresAt, expiresAt.toIso8601String());
  }

  Future<String?> getAccessToken() => read(StorageKeys.authAccessToken);
  Future<String?> getRefreshToken() => read(StorageKeys.authRefreshToken);

  Future<void> saveTwoFactorEnabled(bool isEnabled) async {
    await write(StorageKeys.authTwoFactorEnabled, isEnabled.toString());
  }

  Future<bool> getTwoFactorEnabled() async {
    final value = await read(StorageKeys.authTwoFactorEnabled);
    return value == 'true';
  }

  Future<void> clearAuthData() async {
    await deleteAll();
  }
}
