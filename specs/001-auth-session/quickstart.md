# Quickstart Validation Guide: Authentication & Session Lifecycle

**Feature**: FEAT-01 (Authentication & Session Lifecycle)  
**Date**: 2026-10-02  
**Target API**: `https://todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net`  

---

## 1. Prerequisites & Setup

### Environment Requirements
- Flutter SDK 3.x+ installed (`flutter doctor`)
- Working internet connection to reach Azure backend API
- Mobile emulator (Android/iOS) or physical test device

### Dependencies to add to `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.0.0
  equatable: ^2.0.7
  dio: ^5.8.0
  flutter_secure_storage: ^9.2.4
  go_router: ^14.8.0
```

---

## 2. End-to-End Validation Scenarios

### Scenario 1: New User Registration & Auto-Login
1. Launch app on clean install.
2. Verify app starts at `/login` route.
3. Tap "Hesap Oluştur" (Navigate to `/register`).
4. Enter test email `test_<timestamp>@example.com` and password `Password123!`.
5. Tap "Kayıt Ol".
6. **Expected Outcome**:
   - `POST /api/Auth/register` returns `200 OK` with JWT and refresh token.
   - Tokens stored in `flutter_secure_storage`.
   - `AuthBloc` transitions to `Authenticated`.
   - `GoRouter` redirects to `/` (Home/Task dashboard).

### Scenario 2: Standard Login with Existing Credentials
1. Log out or start on `/login`.
2. Enter valid email and password.
3. Tap "Giriş Yap".
4. **Expected Outcome**:
   - `POST /api/Auth/login` returns `200 OK` with `requiresTwoFactor: false`.
   - User navigated to home screen.

### Scenario 3: 2FA Login Challenge Flow
1. Enter credentials for an account that has 2FA enabled.
2. Tap "Giriş Yap".
3. **Expected Outcome**:
   - `POST /api/Auth/login` returns `200 OK` with `requiresTwoFactor: true` and temporary `twoFactorToken`.
   - `AuthBloc` transitions to `AuthTwoFactorRequired`.
   - App navigates to `/login/2fa`.
4. Enter 6-digit TOTP code from authenticator app.
5. Tap "Doğrula".
6. **Expected Outcome**:
   - `POST /api/Auth/login-2fa` returns `200 OK` with real JWT and refresh token.
   - App navigates to home screen.

### Scenario 4: Token Expiration & Silent Background Refresh
1. Simulate token expiration (or fast-forward token expiry).
2. Trigger an authenticated request (e.g. view tasks).
3. **Expected Outcome**:
   - Request receives `401 Unauthorized`.
   - `Dio` queued interceptor catches 401, calls `POST /api/Auth/refresh` with stored refresh token.
   - Backend returns new JWT + new refresh token (old revoked).
   - Failed request is replayed with new token and succeeds.
   - User experiences **zero interruption** or flash.

### Scenario 5: Session Expiry (Refresh Token Invalid/Revoked)
1. Invalidate or delete refresh token on backend/storage.
2. Trigger an authenticated request.
3. **Expected Outcome**:
   - Refresh attempt fails with `401`.
   - `AuthBloc` transitions to `Unauthenticated`.
   - App navigates to `/login`.
   - SnackBar/Toast displays: *"Oturumunuzun süresi doldu, lütfen tekrar giriş yapın."*

### Scenario 6: User Logout
1. From authenticated state, tap "Çıkış Yap".
2. **Expected Outcome**:
   - `POST /api/Auth/logout` is sent with refresh token.
   - All secure storage keys wiped (`deleteAll()`).
   - `AuthBloc` transitions to `Unauthenticated`.
   - App redirects to `/login`.
   - Closing and reopening the app lands on `/login`.

---

## 3. Automated Test Execution Commands

```bash
# Run unit tests for AuthBloc, Interceptors, and Repository
flutter test test/features/auth/

# Run specific repository tests with mocked Dio
flutter test test/features/auth/data/repositories/auth_repository_test.dart

# Run Bloc state transition tests
flutter test test/features/auth/presentation/bloc/auth_bloc_test.dart
```
