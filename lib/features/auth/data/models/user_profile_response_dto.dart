class UserProfileResponseDto {
  final String userId;
  final String email;
  final String role;
  final bool isTwoFactorEnabled;

  const UserProfileResponseDto({
    required this.userId,
    required this.email,
    required this.role,
    required this.isTwoFactorEnabled,
  });

  factory UserProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseDto(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'role': role,
        'isTwoFactorEnabled': isTwoFactorEnabled,
      };
}

