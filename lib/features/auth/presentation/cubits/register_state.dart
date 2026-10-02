import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? generalError;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.generalError,
  });

  RegisterState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    return RegisterStateImpl(
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

class RegisterStateImpl extends RegisterState {
  const RegisterStateImpl({
    super.email,
    super.password,
    super.emailError,
    super.passwordError,
    super.generalError,
  });
}

class RegisterInitial extends RegisterState {
  const RegisterInitial() : super();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading({required super.email, required super.password});
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess() : super();
}

class RegisterFailure extends RegisterState {
  const RegisterFailure({
    required super.email,
    required super.password,
    super.emailError,
    super.passwordError,
    super.generalError,
  });
}
