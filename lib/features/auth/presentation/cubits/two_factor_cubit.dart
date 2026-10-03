import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'two_factor_state.dart';

class TwoFactorCubit extends Cubit<TwoFactorState> {
  final AuthRepository _authRepository;

  TwoFactorCubit(this._authRepository) : super(const TwoFactorState());

  Future<void> loadStatus() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final isEnabled = await _authRepository.getTwoFactorStatus();
      emit(state.copyWith(
        isLoading: false,
        isEnabled: isEnabled,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'İki faktörlü doğrulama durumu yüklenemedi.',
      ));
    }
  }

  Future<void> initiateSetup() async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    try {
      final response = await _authRepository.enableTwoFactor();
      emit(state.copyWith(
        isSubmitting: false,
        secret: response.secret,
        qrCodeUri: response.qrCodeUri,
        isSetupVisible: true,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Kurulum başlatılamadı. Lütfen tekrar deneyin.',
      ));
    }
  }

  void cancelSetup() {
    emit(state.copyWith(
      isSetupVisible: false,
      clearError: true,
      clearSuccess: true,
    ));
  }

  Future<bool> verifyCode(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.length != 6 || int.tryParse(trimmedCode) == null) {
      emit(state.copyWith(
        errorMessage: 'Lütfen 6 haneli geçerli doğrulama kodunu giriniz.',
      ));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    try {
      final message = await _authRepository.verifyTwoFactor(trimmedCode);
      emit(state.copyWith(
        isSubmitting: false,
        isEnabled: true,
        isSetupVisible: false,
        successMessage: message.isNotEmpty
            ? message
            : 'İki faktörlü doğrulama başarıyla etkinleştirildi.',
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
        errorMessage: 'Kod doğrulanamadı. Lütfen tekrar deneyin.',
      ));
      return false;
    }
  }

  Future<bool> disable2fa(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.length != 6 || int.tryParse(trimmedCode) == null) {
      emit(state.copyWith(
        errorMessage: 'Lütfen 6 haneli geçerli doğrulama kodunu giriniz.',
      ));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));
    try {
      final message = await _authRepository.disableTwoFactor(trimmedCode);
      emit(state.copyWith(
        isSubmitting: false,
        isEnabled: false,
        successMessage: message.isNotEmpty
            ? message
            : 'İki faktörlü doğrulama başarıyla devre dışı bırakıldı.',
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
        errorMessage: 'İşlem gerçekleştirilemedi. Lütfen tekrar deneyin.',
      ));
      return false;
    }
  }
}
