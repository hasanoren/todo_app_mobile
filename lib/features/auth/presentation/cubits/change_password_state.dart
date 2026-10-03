import 'package:equatable/equatable.dart';

class ChangePasswordState extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? confirmPasswordError;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const ChangePasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.currentPasswordError,
    this.newPasswordError,
    this.confirmPasswordError,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isValid =>
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      currentPasswordError == null &&
      newPasswordError == null &&
      confirmPasswordError == null;

  ChangePasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearErrors = false,
    bool clearSuccess = false,
  }) {
    return ChangePasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      currentPasswordError: clearErrors ? null : (currentPasswordError ?? this.currentPasswordError),
      newPasswordError: clearErrors ? null : (newPasswordError ?? this.newPasswordError),
      confirmPasswordError: clearErrors ? null : (confirmPasswordError ?? this.confirmPasswordError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentPassword,
        newPassword,
        confirmPassword,
        currentPasswordError,
        newPasswordError,
        confirmPasswordError,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
