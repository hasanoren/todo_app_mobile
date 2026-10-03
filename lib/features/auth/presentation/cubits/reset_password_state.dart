import 'package:equatable/equatable.dart';

abstract class ResetPasswordState extends Equatable {
  final String token;
  final String newPassword;
  final String confirmPassword;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;
  final bool isTokenInvalid;

  const ResetPasswordState({
    required this.token,
    this.newPassword = '',
    this.confirmPassword = '',
    this.passwordError,
    this.confirmPasswordError,
    this.generalError,
    this.isTokenInvalid = false,
  });

  ResetPasswordState copyWith({
    String? token,
    String? newPassword,
    String? confirmPassword,
    String? passwordError,
    String? confirmPasswordError,
    String? generalError,
    bool? isTokenInvalid,
  }) {
    return ResetPasswordStateImpl(
      token: token ?? this.token,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      generalError: generalError,
      isTokenInvalid: isTokenInvalid ?? this.isTokenInvalid,
    );
  }

  @override
  List<Object?> get props => [
    token,
    newPassword,
    confirmPassword,
    passwordError,
    confirmPasswordError,
    generalError,
    isTokenInvalid,
  ];
}

class ResetPasswordStateImpl extends ResetPasswordState {
  const ResetPasswordStateImpl({
    required super.token,
    super.newPassword,
    super.confirmPassword,
    super.passwordError,
    super.confirmPasswordError,
    super.generalError,
    super.isTokenInvalid = false,
  });
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial({required super.token, super.isTokenInvalid});
}

class ResetPasswordSubmitting extends ResetPasswordState {
  const ResetPasswordSubmitting({
    required super.token,
    required super.newPassword,
    required super.confirmPassword,
  });
}

class ResetPasswordSuccess extends ResetPasswordState {
  final String message;

  const ResetPasswordSuccess({required super.token, required this.message});

  @override
  List<Object?> get props => [...super.props, message];
}

class ResetPasswordFailure extends ResetPasswordState {
  const ResetPasswordFailure({
    required super.token,
    super.newPassword,
    super.confirmPassword,
    super.passwordError,
    super.confirmPasswordError,
    super.generalError,
    super.isTokenInvalid = false,
  });
}
