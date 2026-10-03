import 'dart:convert';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/two_factor_challenge.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/login_2fa_request.dart';
import '../models/refresh_token_request.dart';
import '../models/logout_request.dart';
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';
import '../models/two_factor_verify_request.dart';
import '../models/two_factor_disable_request.dart';
import '../models/two_factor_enable_response_dto.dart';
import '../models/user_profile_response_dto.dart';
import '../models/change_password_request.dart';
import '../models/delete_account_request.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<AuthSession> register(String email, String password) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      final response = await _remoteDataSource.register(request);

      final session = AuthSession(
        userId: response.userId ?? '',
        email: response.email ?? email,
        accessToken: response.token ?? '',
        refreshToken: response.refreshToken ?? '',
        expiresAt: DateTime.now().add(const Duration(minutes: 55)),
      );

      await _secureStorage.saveAuthTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.userId,
        email: session.email,
        expiresAt: session.expiresAt,
      );

      return session;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'A network error occurred.');
    }
  }

  @override
  Future<dynamic> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _remoteDataSource.login(request);

      if (response.requiresTwoFactor) {
        return TwoFactorChallenge(
          twoFactorToken: response.twoFactorToken ?? '',
          email: email,
        );
      }

      String finalEmail = response.email ?? email;
      String finalUserId = response.userId ?? '';
      final token = response.token ?? '';
      if ((finalEmail.isEmpty || finalUserId.isEmpty) && token.isNotEmpty) {
        final claims = _decodeJwtPayload(token);
        if (claims != null) {
          if (finalEmail.isEmpty) {
            final emailClaim = claims['email'] ??
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
            if (emailClaim is String && emailClaim.isNotEmpty) {
              finalEmail = emailClaim;
            }
          }
          if (finalUserId.isEmpty) {
            final sub = claims['sub'] ??
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
            if (sub is String && sub.isNotEmpty) {
              finalUserId = sub;
            }
          }
        }
      }

      final session = AuthSession(
        userId: finalUserId,
        email: finalEmail,
        accessToken: token,
        refreshToken: response.refreshToken ?? '',
        expiresAt: DateTime.now().add(const Duration(minutes: 55)),
      );

      await _secureStorage.saveAuthTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.userId,
        email: session.email,
        expiresAt: session.expiresAt,
      );

      return session;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'A network error occurred.');
    }
  }

  @override
  Future<AuthSession> login2Fa(String twoFactorToken, String code) async {
    try {
      final request = Login2FaRequest(
        twoFactorToken: twoFactorToken,
        code: code,
      );
      final response = await _remoteDataSource.login2Fa(request);

      String finalEmail = response.email ?? '';
      String finalUserId = response.userId ?? '';
      final token = response.token ?? '';
      if ((finalEmail.isEmpty || finalUserId.isEmpty) && token.isNotEmpty) {
        final claims = _decodeJwtPayload(token);
        if (claims != null) {
          if (finalEmail.isEmpty) {
            final emailClaim = claims['email'] ??
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
            if (emailClaim is String && emailClaim.isNotEmpty) {
              finalEmail = emailClaim;
            }
          }
          if (finalUserId.isEmpty) {
            final sub = claims['sub'] ??
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
            if (sub is String && sub.isNotEmpty) {
              finalUserId = sub;
            }
          }
        }
      }

      final session = AuthSession(
        userId: finalUserId,
        email: finalEmail,
        accessToken: token,
        refreshToken: response.refreshToken ?? '',
        expiresAt: DateTime.now().add(const Duration(minutes: 55)),
      );

      await _secureStorage.saveAuthTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.userId,
        email: session.email,
        expiresAt: session.expiresAt,
      );
      await _secureStorage.saveTwoFactorEnabled(true);

      return session;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'A network error occurred.');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      final request = LogoutRequest(refreshToken: refreshToken);
      await _remoteDataSource.logout(request);
    } catch (e) {
      // Even if API fails, we clear local storage below
    } finally {
      await _secureStorage.clearAuthData();
    }
  }

  @override
  Future<void> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _remoteDataSource.refresh(request);

      await _secureStorage.saveAuthTokens(
        accessToken: response.token ?? '',
        refreshToken: response.refreshToken ?? '',
        userId: response.userId ?? '',
        email: response.email ?? '',
        expiresAt: DateTime.now().add(const Duration(minutes: 55)),
      );
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'A network error occurred.');
    }
  }

  @override
  Future<AuthSession?> checkInitialSession() async {
    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();
    final userId = await _secureStorage.read('auth_user_id');
    final email = await _secureStorage.read('auth_email');
    final expiresAtStr = await _secureStorage.read('auth_token_expires_at');

    if (accessToken != null &&
        refreshToken != null &&
        userId != null &&
        email != null &&
        expiresAtStr != null) {
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
        return AuthSession(
          userId: userId,
          email: email,
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );
      }
    }

    return null;
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _remoteDataSource.forgotPassword(request);
      return response.message;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  @override
  Future<String> resetPassword(String token, String newPassword) async {
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );
      final response = await _remoteDataSource.resetPassword(request);
      return response.message;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  @override
  Future<bool> getTwoFactorStatus() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      await _secureStorage.saveTwoFactorEnabled(profile.isTwoFactorEnabled);
      return profile.isTwoFactorEnabled;
    } catch (_) {
      return await _secureStorage.getTwoFactorEnabled();
    }
  }

  @override
  Future<TwoFactorEnableResponseDto> enableTwoFactor() async {
    try {
      final response = await _remoteDataSource.enable2fa();
      return response;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  @override
  Future<String> verifyTwoFactor(String code) async {
    try {
      final request = TwoFactorVerifyRequest(code: code);
      final response = await _remoteDataSource.verify2fa(request);
      await _secureStorage.saveTwoFactorEnabled(true);
      return response.message;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  @override
  Future<String> disableTwoFactor(String code) async {
    try {
      final request = TwoFactorDisableRequest(code: code);
      final response = await _remoteDataSource.disable2fa(request);
      await _secureStorage.saveTwoFactorEnabled(false);
      return response.message;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  @override
  Future<UserProfileResponseDto> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      await _secureStorage.saveTwoFactorEnabled(profile.isTwoFactorEnabled);
      return profile;
    } on ApiException catch (e) {
      if (e.statusCode == 405 || e.statusCode == 404) {
        final localProfile = await _buildLocalProfile();
        if (localProfile != null) {
          return localProfile;
        }
      }
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      final localProfile = await _buildLocalProfile();
      if (localProfile != null) {
        return localProfile;
      }
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  Future<UserProfileResponseDto?> _buildLocalProfile() async {
    String? email = await _secureStorage.read(StorageKeys.authEmail);
    String? userId = await _secureStorage.read(StorageKeys.authUserId);
    final token = await _secureStorage.getAccessToken();

    String role = 'User';
    String finalUserId = userId ?? '';
    String finalEmail = email ?? '';

    if (token != null) {
      final claims = _decodeJwtPayload(token);
      if (claims != null) {
        final roleClaim = claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
            claims['role'];
        if (roleClaim is String && roleClaim.isNotEmpty) {
          role = roleClaim;
        }
        final sub = claims['sub'] ??
            claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
        if (sub is String && sub.isNotEmpty && finalUserId.isEmpty) {
          finalUserId = sub;
          await _secureStorage.write(StorageKeys.authUserId, sub);
        }
        final emailClaim = claims['email'] ??
            claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
        if (emailClaim is String && emailClaim.isNotEmpty && finalEmail.isEmpty) {
          finalEmail = emailClaim;
          await _secureStorage.write(StorageKeys.authEmail, emailClaim);
        }
      }
    }

    if (finalEmail.isEmpty && finalUserId.isEmpty) {
      return null;
    }

    final isTwoFactorEnabled = await _secureStorage.getTwoFactorEnabled();

    return UserProfileResponseDto(
      userId: finalUserId,
      email: finalEmail,
      role: role,
      isTwoFactorEnabled: isTwoFactorEnabled,
    );
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(payloadString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _remoteDataSource.changePassword(request);
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final request = DeleteAccountRequest(password: password);
      await _remoteDataSource.deleteAccount(request);
      await _secureStorage.clearAuthData();
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
    }
  }
}
