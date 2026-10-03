# Data Models: Two-Factor Authentication Management (FEAT-03)

## Entities & DTOs

### 1. TwoFactorEnableResponseDto
Represents the payload returned by `POST /api/Auth/2fa/enable`.
```dart
class TwoFactorEnableResponseDto {
  final String secret;
  final String qrCodeUri;

  const TwoFactorEnableResponseDto({
    required this.secret,
    required this.qrCodeUri,
  });

  factory TwoFactorEnableResponseDto.fromJson(Map<String, dynamic> json) {
    return TwoFactorEnableResponseDto(
      secret: json['secret'] as String? ?? '',
      qrCodeUri: json['qrCodeUri'] as String? ?? '',
    );
  }
}
```

### 2. TwoFactorVerifyRequest
Request body for `POST /api/Auth/2fa/verify`.
```dart
class TwoFactorVerifyRequest {
  final String code;

  const TwoFactorVerifyRequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
```

### 3. TwoFactorDisableRequest
Request body for `POST /api/Auth/2fa/disable`.
```dart
class TwoFactorDisableRequest {
  final String code;

  const TwoFactorDisableRequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
```

### 4. UserProfileResponseDto
Represents current user information returned by `GET /api/Users/me`.
```dart
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
}
```
