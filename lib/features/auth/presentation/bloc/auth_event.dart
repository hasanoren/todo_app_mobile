import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String userId;

  const LoggedIn({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class TwoFactorRequired extends AuthEvent {
  final String twoFactorToken;
  final String email;

  const TwoFactorRequired({required this.twoFactorToken, required this.email});

  @override
  List<Object?> get props => [twoFactorToken, email];
}

class LoggedOut extends AuthEvent {}

class SessionExpired extends AuthEvent {}

class RefreshRequested extends AuthEvent {}
