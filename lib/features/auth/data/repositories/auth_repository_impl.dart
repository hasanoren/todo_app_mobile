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
  Future<AuthSession> login2Fa(String twoFactorToken, String code) async {
    try {
      final request = Login2FaRequest(
        twoFactorToken: twoFactorToken,
        code: code,
      );
      final response = await _remoteDataSource.login2Fa(request);

      final session = AuthSession(
        userId: response.userId ?? '',
        email: response.email ?? '', // Email ideally preserved or fetched
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
      return profile.isTwoFactorEnabled;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
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
      return profile;
    } on ApiException catch (e) {
      throw ServerFailure(message: e.detail, validationErrors: e.errors);
    } catch (e) {
      throw const NetworkFailure(message: 'Bir ağ hatası oluştu.');
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
