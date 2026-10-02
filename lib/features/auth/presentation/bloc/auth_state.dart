import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final String userId;

  const Authenticated(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AuthTwoFactorRequiredState extends AuthState {
  final String twoFactorToken;
  final String email;

  const AuthTwoFactorRequiredState({
    required this.twoFactorToken,
    required this.email,
  });

  @override
  List<Object?> get props => [twoFactorToken, email];
}

class Unauthenticated extends AuthState {}
