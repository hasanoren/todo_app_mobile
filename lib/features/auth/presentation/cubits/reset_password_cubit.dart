import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordCubit(this._authRepository, {required String token})
    : super(
        ResetPasswordInitial(
          token: token,
          isTokenInvalid: token.trim().isEmpty,
        ),
      );

  void newPasswordChanged(String password) {
    emit(
      state.copyWith(
        newPassword: password,
        passwordError: null,
        generalError: null,
      ),
    );
  }

  void confirmPasswordChanged(String confirmPassword) {
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        confirmPasswordError: null,
        generalError: null,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isTokenInvalid) {
      emit(
        ResetPasswordFailure(
          token: state.token,
          isTokenInvalid: true,
          generalError: 'Sıfırlama bağlantısının süresi dolmuş veya geçersiz. Lütfen yeni bir bağlantı talep edin.',
        ),
      );
      return;
    }

    if (!_validateFields()) return;

    emit(
      ResetPasswordSubmitting(
        token: state.token,
        newPassword: state.newPassword,
        confirmPassword: state.confirmPassword,
      ),
    );

    try {
      final message = await _authRepository.resetPassword(
        state.token,
        state.newPassword,
      );
      emit(
        ResetPasswordSuccess(
          token: state.token,
          message: message.isNotEmpty ? message : 'Şifreniz başarıyla değiştirildi. Yeni şifrenizle giriş yapabilirsiniz.',
        ),
      );
    } on ServerFailure catch (e) {
      String? passwordError;
      bool isTokenInvalid = false;

      if (e.validationErrors != null) {
        if (e.validationErrors!['newPassword'] != null) {
          passwordError = e.validationErrors!['newPassword']!.join('\n');
        }
        if (e.validationErrors!['token'] != null) {
          isTokenInvalid = true;
        }
      }

      // Check detail text for token expiration or invalidity
      final detail = e.message.toLowerCase();
      if (detail.contains('token') ||
          detail.contains('expired') ||
          detail.contains('geçersiz') ||
          detail.contains('süresi')) {
        isTokenInvalid = true;
      }

      emit(
        ResetPasswordFailure(
          token: state.token,
          newPassword: state.newPassword,
          confirmPassword: state.confirmPassword,
          passwordError: passwordError,
          isTokenInvalid: isTokenInvalid,
          generalError: isTokenInvalid
              ? 'Sıfırlama bağlantısının süresi dolmuş veya geçersiz. Lütfen yeni bir bağlantı talep edin.'
              : e.message,
        ),
      );
    } on NetworkFailure catch (e) {
      emit(
        ResetPasswordFailure(
          token: state.token,
          newPassword: state.newPassword,
          confirmPassword: state.confirmPassword,
          generalError: e.message,
        ),
      );
    } catch (_) {
      emit(
        ResetPasswordFailure(
          token: state.token,
          newPassword: state.newPassword,
          confirmPassword: state.confirmPassword,
          generalError: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  bool _validateFields() {
    String? passwordError;
    String? confirmPasswordError;

    final password = state.newPassword;
    if (password.length < 8) {
      passwordError = 'Şifre en az 8 karakter olmalıdır.';
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      passwordError = 'Şifre en az 1 büyük harf içermelidir.';
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      passwordError = 'Şifre en az 1 rakam içermelidir.';
    } else if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=]'))) {
      passwordError = 'Şifre en az 1 özel karakter içermelidir.';
    }

    if (state.confirmPassword != password) {
      confirmPasswordError = 'Şifreler eşleşmiyor.';
    }

    if (passwordError != null || confirmPasswordError != null) {
      emit(
        state.copyWith(
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
      return false;
    }

    return true;
  }
}
