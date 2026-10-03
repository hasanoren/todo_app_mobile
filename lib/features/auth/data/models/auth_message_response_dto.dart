class AuthMessageResponseDto {
  final String message;

  const AuthMessageResponseDto({required this.message});

  factory AuthMessageResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthMessageResponseDto(message: json['message'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'message': message};
}
