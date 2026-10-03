import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;
  Timer? _cooldownTimer;

  ForgotPasswordCubit(this._authRepository)
    : super(const ForgotPasswordInitial());

  void emailChanged(String email) {
    emit(state.copyWith(email: email, emailError: null, generalError: null));
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    emit(state.copyWith(cooldownSeconds: 60));

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.cooldownSeconds <= 1) {
        timer.cancel();
        emit(state.copyWith(cooldownSeconds: 0));
      } else {
        emit(state.copyWith(cooldownSeconds: state.cooldownSeconds - 1));
      }
    });
  }

  Future<void> submit() async {
    if (state.isCooldownActive) return;
    if (!_validateEmail()) return;

    emit(
      ForgotPasswordSubmitting(
        email: state.email,
        cooldownSeconds: state.cooldownSeconds,
      ),
    );

    try {
      final message = await _authRepository.forgotPassword(state.email.trim());
      _startCooldown();
      emit(
        ForgotPasswordSuccess(
          email: state.email,
          cooldownSeconds: 60,
          successMessage: message.isNotEmpty ? message : 'Eğer bu e-posta adresi kayıtlıysa, şifre sıfırlama bağlantısı gönderilmiştir.',
        ),
      );
    } on ServerFailure catch (e) {
      String? emailError;
      if (e.validationErrors != null && e.validationErrors!['email'] != null) {
        emailError = e.validationErrors!['email']!.join('\n');
      }
      emit(
        ForgotPasswordFailure(
          email: state.email,
          emailError: emailError,
          generalError: e.message,
        ),
      );
    } on NetworkFailure catch (e) {
      emit(ForgotPasswordFailure(email: state.email, generalError: e.message));
    } catch (_) {
      emit(
        ForgotPasswordFailure(
          email: state.email,
          generalError: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  bool _validateEmail() {
    final email = state.email.trim();
    if (email.isEmpty) {
      emit(state.copyWith(emailError: 'E-posta adresi boş bırakılamaz.'));
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      emit(state.copyWith(emailError: 'Geçerli bir e-posta adresi giriniz.'));
      return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
