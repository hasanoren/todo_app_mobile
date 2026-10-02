import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  final String userId;
  final String email;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    accessToken,
    refreshToken,
    expiresAt,
  ];
}
