import 'package:equatable/equatable.dart';

class TwoFactorState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool isEnabled;
  final String? secret;
  final String? qrCodeUri;
  final String? errorMessage;
  final String? successMessage;
  final bool isSetupVisible;

  const TwoFactorState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isEnabled = false,
    this.secret,
    this.qrCodeUri,
    this.errorMessage,
    this.successMessage,
    this.isSetupVisible = false,
  });

  TwoFactorState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isEnabled,
    String? secret,
    String? qrCodeUri,
    String? errorMessage,
    String? successMessage,
    bool? isSetupVisible,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TwoFactorState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isEnabled: isEnabled ?? this.isEnabled,
      secret: secret ?? this.secret,
      qrCodeUri: qrCodeUri ?? this.qrCodeUri,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isSetupVisible: isSetupVisible ?? this.isSetupVisible,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        isEnabled,
        secret,
        qrCodeUri,
        errorMessage,
        successMessage,
        isSetupVisible,
      ];
}
