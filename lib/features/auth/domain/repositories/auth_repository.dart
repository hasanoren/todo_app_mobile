import '../entities/auth_session.dart';
import '../entities/two_factor_challenge.dart';

abstract class AuthRepository {
  /// Returns either an [AuthSession] if standard login succeeds,
  /// or a [TwoFactorChallenge] if 2FA is required.
  Future<dynamic> login(String email, String password);

  Future<AuthSession> login2Fa(String twoFactorToken, String code);

  Future<AuthSession> register(String email, String password);

  Future<void> logout(String refreshToken);

  Future<void> refreshToken(String refreshToken);

  Future<AuthSession?> checkInitialSession();

  Future<String> forgotPassword(String email);

  Future<String> resetPassword(String token, String newPassword);

  Future<bool> getTwoFactorStatus();

  Future<dynamic> enableTwoFactor();

  Future<String> verifyTwoFactor(String code);

  Future<String> disableTwoFactor(String code);

  Future<dynamic> getProfile();

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> deleteAccount(String password);
}
