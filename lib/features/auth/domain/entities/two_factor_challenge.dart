import 'package:equatable/equatable.dart';

class TwoFactorChallenge extends Equatable {
  final String twoFactorToken;
  final String email;

  const TwoFactorChallenge({required this.twoFactorToken, required this.email});

  @override
  List<Object?> get props => [twoFactorToken, email];
}
