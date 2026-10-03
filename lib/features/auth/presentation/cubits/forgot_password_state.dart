import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  final String email;
  final String? emailError;
  final int cooldownSeconds;
  final String? successMessage;
  final String? generalError;

  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.cooldownSeconds = 0,
    this.successMessage,
    this.generalError,
  });

  bool get isCooldownActive => cooldownSeconds > 0;

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    int? cooldownSeconds,
    String? successMessage,
    String? generalError,
  }) {
    return ForgotPasswordStateImpl(
      email: email ?? this.email,
      emailError: emailError,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      successMessage: successMessage,
      generalError: generalError,
    );
  }

  @override
  List<Object?> get props => [
    email,
    emailError,
    cooldownSeconds,
    successMessage,
    generalError,
  ];
}

class ForgotPasswordStateImpl extends ForgotPasswordState {
  const ForgotPasswordStateImpl({
    super.email,
    super.emailError,
    super.cooldownSeconds,
    super.successMessage,
    super.generalError,
  });
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial() : super();
}

class ForgotPasswordSubmitting extends ForgotPasswordState {
  const ForgotPasswordSubmitting({required super.email, super.cooldownSeconds});
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess({
    required super.email,
    required super.cooldownSeconds,
    required super.successMessage,
  });
}

class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure({
    required super.email,
    super.emailError,
    super.cooldownSeconds = 0,
    super.generalError,
  });
}
