import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? generalError;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.generalError,
  });

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    return LoginStateImpl(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      generalError: generalError,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    emailError,
    passwordError,
    generalError,
  ];
}

class LoginStateImpl extends LoginState {
  const LoginStateImpl({
    super.email,
    super.password,
    super.emailError,
    super.passwordError,
    super.generalError,
  });
}

class LoginInitial extends LoginState {
  const LoginInitial() : super();
}

class LoginLoading extends LoginState {
  const LoginLoading({required super.email, required super.password});
}

class LoginSuccess extends LoginState {
  final bool requiresTwoFactor;
  final String? twoFactorToken;

  const LoginSuccess({required this.requiresTwoFactor, this.twoFactorToken})
    : super();

  @override
  List<Object?> get props => [requiresTwoFactor, twoFactorToken];
}

class LoginFailure extends LoginState {
  const LoginFailure({
    required super.email,
    required super.password,
    super.emailError,
    super.passwordError,
    super.generalError,
  });
}
