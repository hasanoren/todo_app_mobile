import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit(this._authRepository) : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final profile = await _authRepository.getProfile();
      emit(state.copyWith(
        isLoading: false,
        profile: profile,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Profil bilgileri yüklenemedi.',
      ));
    }
  }

  Future<bool> deleteAccount(String password) async {
    final trimmedPassword = password.trim();
    if (trimmedPassword.isEmpty) {
      emit(state.copyWith(
        deletionError: 'Hesabınızı silmek için şifrenizi girmeniz zorunludur.',
      ));
      return false;
    }

    emit(state.copyWith(isDeleting: true, clearDeletionError: true));
    try {
      await _authRepository.deleteAccount(trimmedPassword);
      emit(state.copyWith(
        isDeleting: false,
        deletionSuccess: true,
      ));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(
        isDeleting: false,
        deletionError: f.message,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isDeleting: false,
        deletionError: 'Hesap silme işlemi başarısız oldu. Lütfen tekrar deneyin.',
      ));
      return false;
    }
  }
}
