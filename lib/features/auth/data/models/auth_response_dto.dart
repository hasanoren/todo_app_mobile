class AuthResponseDto {
  final String? userId;
  final String? email;
  final String? token;
  final String? refreshToken;
  final bool requiresTwoFactor;
  final String? twoFactorToken;

  AuthResponseDto({
    this.userId,
    this.email,
    this.token,
    this.refreshToken,
    required this.requiresTwoFactor,
    this.twoFactorToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      requiresTwoFactor: json['requiresTwoFactor'] as bool? ?? false,
      twoFactorToken: json['twoFactorToken'] as String?,
    );
  }
}
