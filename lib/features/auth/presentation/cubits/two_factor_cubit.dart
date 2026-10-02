import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import 'two_factor_state.dart';

class TwoFactorCubit extends Cubit<TwoFactorState> {
  final AuthRepository _authRepository;
  final String _twoFactorToken;

  TwoFactorCubit(this._authRepository, this._twoFactorToken)
    : super(const TwoFactorInitial());

  void codeChanged(String code) {
    emit(state.copyWith(code: code));
  }

  Future<void> submit() async {
    if (!_validateFields()) return;

    emit(TwoFactorLoading(code: state.code));

    try {
      await _authRepository.login2Fa(_twoFactorToken, state.code);
      emit(const TwoFactorSuccess());
    } on ServerFailure catch (e) {
      String? codeError;
      if (e.validationErrors != null) {
        codeError = e.validationErrors!['code']?.join('\n');
      }
      emit(
        TwoFactorFailure(
          code: state.code,
          codeError: codeError,
          generalError: e.message,
        ),
      );
    } on NetworkFailure catch (e) {
      emit(TwoFactorFailure(code: state.code, generalError: e.message));
    } catch (_) {
      emit(
        TwoFactorFailure(
          code: state.code,
          generalError: '2FA doğrulama başarısız oldu.',
        ),
      );
    }
  }

  bool _validateFields() {
    String? codeError;

    final regex = RegExp(r'^\d{6}$');
    if (!regex.hasMatch(state.code)) {
      codeError = 'Geçerli 6 haneli kodu girin.';
    }

    if (codeError != null) {
      emit(TwoFactorFailure(code: state.code, codeError: codeError));
      return false;
    }

    return true;
  }
}
