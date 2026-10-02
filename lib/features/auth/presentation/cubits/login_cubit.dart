import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/two_factor_challenge.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginInitial());

  void emailChanged(String email) {
    emit(state.copyWith(email: email));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> submit() async {
    if (!_validateFields()) return;

    emit(LoginLoading(email: state.email, password: state.password));

    try {
      final result = await _authRepository.login(state.email, state.password);

      if (result is TwoFactorChallenge) {
        emit(
          LoginSuccess(
            requiresTwoFactor: true,
            twoFactorToken: result.twoFactorToken,
          ),
        );
      } else {
        emit(const LoginSuccess(requiresTwoFactor: false));
      }
    } on ServerFailure catch (e) {
      String? emailError;
      String? passwordError;
      if (e.validationErrors != null) {
        emailError = e.validationErrors!['email']?.join('\n');
        passwordError = e.validationErrors!['password']?.join('\n');
      }
      emit(
        LoginFailure(
          email: state.email,
          password: state.password,
          emailError: emailError,
          passwordError: passwordError,
          generalError: e.message,
        ),
      );
    } on NetworkFailure catch (e) {
      emit(
        LoginFailure(
          email: state.email,
          password: state.password,
          generalError: e.message,
        ),
      );
    } catch (_) {
      emit(
        LoginFailure(
          email: state.email,
          password: state.password,
          generalError: 'Giriş işlemi başarısız oldu.',
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

    if (state.password.isEmpty) {
      passwordError = 'Şifre boş olamaz.';
    }

    if (emailError != null || passwordError != null) {
      emit(
        LoginFailure(
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
