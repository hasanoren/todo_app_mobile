import 'package:equatable/equatable.dart';

abstract class TwoFactorState extends Equatable {
  final String code;
  final String? codeError;
  final String? generalError;

  const TwoFactorState({this.code = '', this.codeError, this.generalError});

  TwoFactorState copyWith({
    String? code,
    String? codeError,
    String? generalError,
  }) {
    return TwoFactorStateImpl(
      code: code ?? this.code,
      codeError: codeError,
      generalError: generalError,
    );
  }

  @override
  List<Object?> get props => [code, codeError, generalError];
}

class TwoFactorStateImpl extends TwoFactorState {
  const TwoFactorStateImpl({super.code, super.codeError, super.generalError});
}

class TwoFactorInitial extends TwoFactorState {
  const TwoFactorInitial() : super();
}

class TwoFactorLoading extends TwoFactorState {
  const TwoFactorLoading({required super.code});
}

class TwoFactorSuccess extends TwoFactorState {
  const TwoFactorSuccess() : super();
}

class TwoFactorFailure extends TwoFactorState {
  const TwoFactorFailure({
    required super.code,
    super.codeError,
    super.generalError,
  });
}
