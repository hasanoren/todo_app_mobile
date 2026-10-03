import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/core/errors/failure.dart';
import 'package:todo_app_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:todo_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app_mobile/features/auth/data/models/two_factor_enable_response_dto.dart';
import 'package:todo_app_mobile/features/auth/data/models/user_profile_response_dto.dart';
import 'package:todo_app_mobile/features/auth/presentation/cubits/change_password_cubit.dart';
import 'package:todo_app_mobile/features/auth/presentation/cubits/profile_cubit.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFailGetProfile = false;
  bool shouldFailChangePassword = false;
  bool shouldFailDeleteAccount = false;

  @override
  Future<UserProfileResponseDto> getProfile() async {
    if (shouldFailGetProfile) {
      throw const ServerFailure(message: 'Sunucu hatası');
    }
    return const UserProfileResponseDto(
      userId: 'test-user-id',
      email: 'test@example.com',
      role: 'User',
      isTwoFactorEnabled: true,
    );
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (shouldFailChangePassword) {
      throw const ServerFailure(message: 'Mevcut şifre hatalı.');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    if (shouldFailDeleteAccount) {
      throw const ServerFailure(message: 'Şifre hatalı.');
    }
  }

  @override
  Future<AuthSession?> checkInitialSession() async => null;

  @override
  Future<dynamic> login(String email, String password) async => null;

  @override
  Future<AuthSession> login2Fa(String twoFactorToken, String code) async =>
      throw UnimplementedError();

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> refreshToken(String refreshToken) async {}

  @override
  Future<AuthSession> register(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<String> forgotPassword(String email) async => 'Sent';

  @override
  Future<String> resetPassword(String token, String newPassword) async => 'Reset';

  @override
  Future<TwoFactorEnableResponseDto> enableTwoFactor() async =>
      throw UnimplementedError();

  @override
  Future<String> verifyTwoFactor(String code) async => 'Verified';

  @override
  Future<String> disableTwoFactor(String code) async => 'Disabled';

  @override
  Future<bool> getTwoFactorStatus() async => true;
}

void main() {
  group('ProfileCubit', () {
    late FakeAuthRepository authRepository;
    late ProfileCubit profileCubit;

    setUp(() {
      authRepository = FakeAuthRepository();
      profileCubit = ProfileCubit(authRepository);
    });

    tearDown(() {
      profileCubit.close();
    });

    test('loadProfile loads profile data successfully', () async {
      await profileCubit.loadProfile();

      expect(profileCubit.state.isLoading, false);
      expect(profileCubit.state.profile, isNotNull);
      expect(profileCubit.state.profile?.email, 'test@example.com');
      expect(profileCubit.state.profile?.isTwoFactorEnabled, true);
      expect(profileCubit.state.errorMessage, isNull);
    });

    test('loadProfile emits error when repository fails', () async {
      authRepository.shouldFailGetProfile = true;
      await profileCubit.loadProfile();

      expect(profileCubit.state.isLoading, false);
      expect(profileCubit.state.profile, isNull);
      expect(profileCubit.state.errorMessage, 'Sunucu hatası');
    });

    test('deleteAccount requires password', () async {
      final result = await profileCubit.deleteAccount('   ');

      expect(result, false);
      expect(profileCubit.state.deletionError, contains('zorunludur'));
    });

    test('deleteAccount succeeds with correct password', () async {
      final result = await profileCubit.deleteAccount('CorrectPass123!');

      expect(result, true);
      expect(profileCubit.state.deletionSuccess, true);
    });
  });

  group('ChangePasswordCubit', () {
    late FakeAuthRepository authRepository;
    late ChangePasswordCubit changePasswordCubit;

    setUp(() {
      authRepository = FakeAuthRepository();
      changePasswordCubit = ChangePasswordCubit(authRepository);
    });

    tearDown(() {
      changePasswordCubit.close();
    });

    test('changePassword validates empty current password', () async {
      final result = await changePasswordCubit.submit();

      expect(result, false);
      expect(changePasswordCubit.state.currentPasswordError, contains('Mevcut şifre'));
    });

    test('changePassword validates new password length and characters', () async {
      changePasswordCubit.currentPasswordChanged('OldPass123!');
      changePasswordCubit.newPasswordChanged('weak');

      final result = await changePasswordCubit.submit();

      expect(result, false);
      expect(changePasswordCubit.state.newPasswordError, contains('en az 8 karakter'));
    });

    test('changePassword validates matching passwords', () async {
      changePasswordCubit.currentPasswordChanged('OldPass123!');
      changePasswordCubit.newPasswordChanged('NewPass123!');
      changePasswordCubit.confirmPasswordChanged('DifferentPass123!');

      final result = await changePasswordCubit.submit();

      expect(result, false);
      expect(changePasswordCubit.state.confirmPasswordError, contains('eşleşmiyor'));
    });

    test('changePassword succeeds with valid inputs', () async {
      changePasswordCubit.currentPasswordChanged('OldPass123!');
      changePasswordCubit.newPasswordChanged('NewPass123!');
      changePasswordCubit.confirmPasswordChanged('NewPass123!');

      final result = await changePasswordCubit.submit();

      expect(result, true);
      expect(changePasswordCubit.state.successMessage, contains('başarıyla'));
    });
  });
}
