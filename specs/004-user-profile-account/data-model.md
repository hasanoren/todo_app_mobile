# Data Models: User Profile & Account Management (FEAT-04)

## Entities & DTOs

### 1. ChangePasswordRequest
Request payload for `PUT /api/Auth/change-password`.
```dart
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}
```

### 2. DeleteAccountRequest
Request payload for `DELETE /api/Users/me`.
```dart
class DeleteAccountRequest {
  final String password;

  const DeleteAccountRequest({required this.password});

  Map<String, dynamic> toJson() => {'password': password};
}
```

### 3. UserProfileResponseDto
Existing model from FEAT-03 (`lib/features/auth/data/models/user_profile_response_dto.dart`):
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
}
```

## Presentation State Models

### 1. ProfileState (ProfileCubit)
Manages user profile data and account deletion lifecycle:
- `isLoading`: bool
- `isDeleting`: bool
- `profile`: UserProfileResponseDto?
- `errorMessage`: String?
- `deletionSuccess`: bool

### 2. ChangePasswordState (ChangePasswordCubit)
Manages the password change form:
- `currentPassword`: String
- `newPassword`: String
- `confirmPassword`: String
- `currentPasswordError`: String?
- `newPasswordError`: String?
- `confirmPasswordError`: String?
- `isSubmitting`: bool
- `errorMessage`: String?
- `successMessage`: String?
