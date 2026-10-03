import 'package:equatable/equatable.dart';

abstract class Login2faState extends Equatable {
  final String code;
  final String? codeError;
  final String? generalError;

  const Login2faState({
    this.code = '',
    this.codeError,
    this.generalError,
  });

  Login2faState copyWith({
    String? code,
    String? codeError,
    String? generalError,
  }) {
    return Login2faStateImpl(
      code: code ?? this.code,
      codeError: codeError,
      generalError: generalError,
    );
  }

  @override
  List<Object?> get props => [code, codeError, generalError];
}

class Login2faStateImpl extends Login2faState {
  const Login2faStateImpl({
    super.code,
    super.codeError,
    super.generalError,
  });
}

class Login2faInitial extends Login2faState {
  const Login2faInitial() : super();
}

class Login2faLoading extends Login2faState {
  const Login2faLoading({super.code});
}

class Login2faSuccess extends Login2faState {
  const Login2faSuccess() : super();
}

class Login2faFailure extends Login2faState {
  const Login2faFailure({
    super.code,
    super.codeError,
    super.generalError,
  });
}
