import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _authRepository;

  ChangePasswordCubit(this._authRepository)
      : super(const ChangePasswordState());

  void currentPasswordChanged(String value) {
    String? error;
    if (value.trim().isEmpty) {
      error = 'Mevcut şifre boş bırakılamaz.';
    }
    emit(state.copyWith(
      currentPassword: value,
      currentPasswordError: error,
      clearErrors: error == null,
    ));
  }

  void newPasswordChanged(String value) {
    String? error = _validatePassword(value);
    String? confirmError = state.confirmPassword.isNotEmpty &&
            value != state.confirmPassword
        ? 'Şifreler eşleşmiyor.'
        : null;

    emit(state.copyWith(
      newPassword: value,
      newPasswordError: error,
      confirmPasswordError: confirmError,
      clearErrors: error == null && confirmError == null,
    ));
  }

  void confirmPasswordChanged(String value) {
    String? error;
    if (value != state.newPassword) {
      error = 'Şifreler eşleşmiyor.';
    }
    emit(state.copyWith(
      confirmPassword: value,
      confirmPasswordError: error,
      clearErrors: error == null,
    ));
  }

  String? _validatePassword(String value) {
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'En az bir büyük harf içermelidir.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'En az bir rakam içermelidir.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'En az bir özel karakter içermelidir.';
    }
    return null;
  }

  Future<bool> submit() async {
    final currentError = state.currentPassword.trim().isEmpty
        ? 'Mevcut şifre boş bırakılamaz.'
        : null;
    final newError = _validatePassword(state.newPassword);
    final confirmError = state.newPassword != state.confirmPassword
        ? 'Şifreler eşleşmiyor.'
        : null;

    if (currentError != null || newError != null || confirmError != null) {
      emit(state.copyWith(
        currentPasswordError: currentError,
        newPasswordError: newError,
        confirmPasswordError: confirmError,
      ));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrors: true, clearSuccess: true));

    try {
      await _authRepository.changePassword(
        state.currentPassword,
        state.newPassword,
      );
      emit(const ChangePasswordState(
        successMessage: 'Şifreniz başarıyla değiştirildi.',
      ));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: f.message,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Şifre değiştirilemedi. Lütfen tekrar deneyin.',
      ));
      return false;
    }
  }

  void reset() {
    emit(const ChangePasswordState());
  }
}
