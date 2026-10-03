# Data Model: FEAT-02 — Password Recovery & Deep Linking

**Feature**: FEAT-02 — Password Recovery & Deep Linking  
**Date**: 2026-10-03  
**Status**: Ready  

---

## 1. Domain Entities & Value Objects

Şifre kurtarma akışı tek kullanımlık işlemler içerdiğinden yerel olarak kalıcı bir veritabanı kaydı tutulmaz. Bellek üzerinde yönetilen değer nesneleri şunlardır:

### ResetToken
Derin bağlantı (deep link) ile gelen ve sunucuya şifre sıfırlama talebinde bulunurken kullanılan güvenlik anahtarı.
- `rawToken`: `String` — URL'den okunan ve decode edilmiş ham belirteç.
- `isValid`: `bool` — Belirtecin boş olmaması ve asgari uzunluk kontrolü.

---

## 2. Data Transfer Objects (DTOs)

### ForgotPasswordRequest
`POST /api/Auth/forgot-password` endpoint'ine gönderilen gövde (body).

```dart
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}
```

### ResetPasswordRequest
`POST /api/Auth/reset-password` endpoint'ine gönderilen gövde (body).

```dart
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'newPassword': newPassword,
  };
}
```

### AuthMessageResponseDto
Her iki uç noktadan dönen standart mesaj yanıtı.

```dart
class AuthMessageResponseDto {
  final String message;

  const AuthMessageResponseDto({required this.message});

  factory AuthMessageResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthMessageResponseDto(
      message: json['message'] as String? ?? '',
    );
  }
}
```

---

## 3. Presentation State Models (Cubit States)

### ForgotPasswordState
`ForgotPasswordCubit` tarafından yönetilen arayüz durumu.

```dart
abstract class ForgotPasswordState extends Equatable {
  final String email;
  final String? emailError;
  final int cooldownSeconds; // 0 ise buton aktif, > 0 ise geri sayım devrede
  final String? successMessage;
  final String? generalError;

  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.cooldownSeconds = 0,
    this.successMessage,
    this.generalError,
  });
}
```

**State Transitions:**
1. `ForgotPasswordInitial` → Kullanıcı ekrana ilk girdiğinde.
2. `ForgotPasswordSubmitting` → E-posta gönder butonuna tıklandığında (loading spinner).
3. `ForgotPasswordSuccess` → API başarılı döndüğünde (60 saniyelik sayaç başlar, `cooldownSeconds: 60`).
4. `ForgotPasswordFailure` → Sunucu hatası veya 429 durumunda.

---

### ResetPasswordState
`ResetPasswordCubit` tarafından yönetilen arayüz durumu.

```dart
abstract class ResetPasswordState extends Equatable {
  final String token;
  final String newPassword;
  final String confirmPassword;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;
  final bool isTokenInvalid; // Token boş veya bozuk geldiğinde true

  const ResetPasswordState({
    required this.token,
    this.newPassword = '',
    this.confirmPassword = '',
    this.passwordError,
    this.confirmPasswordError,
    this.generalError,
    this.isTokenInvalid = false,
  });
}
```

**State Transitions:**
1. `ResetPasswordInitial` → Derin bağlantıdan gelen token ile ekran açıldığında.
2. `ResetPasswordSubmitting` → Yeni şifre gönderilirken.
3. `ResetPasswordSuccess` → Şifre güncellendiğinde (Login ekranına yönlendirme tetiklenir).
4. `ResetPasswordFailure` → Token süresi dolmuş veya hatalı şifre kuralları olduğunda.
