import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  void emailChanged(String email) {
    emit(state.copyWith(email: email));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> submit() async {
    if (!_validateFields()) return;

    emit(RegisterLoading(email: state.email, password: state.password));

    try {
      await _authRepository.register(
        state.email,
        state.password,
      );
      emit(const RegisterSuccess());
    } on ServerFailure catch (e) {
      String? emailError;
      String? passwordError;
      if (e.validationErrors != null) {
        emailError = e.validationErrors!['email']?.join('\n');
        passwordError = e.validationErrors!['password']?.join('\n');
      }
      emit(
        RegisterFailure(
          email: state.email,
          password: state.password,
          emailError: emailError,
          passwordError: passwordError,
          generalError: e.message,
        ),
      );
    } on NetworkFailure catch (e) {
      emit(
        RegisterFailure(
          email: state.email,
          password: state.password,
          generalError: e.message,
        ),
      );
    } catch (_) {
      emit(
        RegisterFailure(
          email: state.email,
          password: state.password,
          generalError: 'Kayıt işlemi başarısız oldu.',
        ),
      );
    }
  }

  bool _validateFields() {
    String? emailError;
    String? passwordError;

    if (state.email.isEmpty || !state.email.contains('@')) {
      emailError = 'Geçerli bir e-posta adresi girin.';
    }

    final hasMinLength = state.password.length >= 8;
    final hasUpper = state.password.contains(RegExp(r'[A-Z]'));
    final hasLower = state.password.contains(RegExp(r'[a-z]'));
    final hasNumber = state.password.contains(RegExp(r'[0-9]'));
    final hasSpecial = state.password.contains(
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]'),
    );

    if (!hasMinLength || !hasUpper || !hasLower || !hasNumber || !hasSpecial) {
      passwordError = 'Şifre en az 8 karakter olmalı; büyük harf, küçük harf, rakam ve özel karakter içermelidir.';
    }

    if (emailError != null || passwordError != null) {
      emit(
        RegisterFailure(
          email: state.email,
          password: state.password,
          emailError: emailError,
          passwordError: passwordError,
        ),
      );
      return false;
    }

    return true;
  }
}
