# Phase 0 Research: Two-Factor Authentication Management (FEAT-03)

## Objective
Enable authenticated users to manage their TOTP-based Two-Factor Authentication (2FA) lifecycle: checking current status, initiating setup with QR code and secret display, verifying 6-digit TOTP code to activate, and disabling 2FA with a valid TOTP code.

## Key Technical Decisions

### 1. QR Code Generation
- **Decision**: Use `qr_flutter: ^4.1.0`.
- **Rationale**: `qr_flutter` renders QR codes purely in Dart using `CustomPainter` onto Flutter's `Canvas`. It requires no platform channels, native Android/iOS dependencies, or internet connectivity to render.
- **Input Data**: The API returns `qrCodeUri` formatted as a standard `otpauth://` URI:
  `otpauth://totp/TodoApp:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=TodoApp`
- **Implementation**:
  ```dart
  QrImageView(
    data: qrCodeUri,
    version: QrVersions.auto,
    size: 200.0,
  )
  ```

### 2. Manual Secret Key Entry & Clipboard Access
- **Decision**: Display the Base32 `secret` string beneath the QR code with a "Panoya Kopyala" (Copy to Clipboard) button using Flutter's built-in `Clipboard.setData(ClipboardData(text: secret))`.
- **Rationale**: If users cannot scan the QR code (e.g. running the authenticator app on the same physical phone), they can copy the secret and paste it directly into Google Authenticator or Microsoft Authenticator.

### 3. API Contract & Endpoints
- **Endpoints**:
  1. `GET /api/Users/me`: Retrieves user profile including `isTwoFactorEnabled: bool` to determine UI state.
  2. `POST /api/Auth/2fa/enable`: Returns `{ "secret": "...", "qrCodeUri": "..." }`. Does NOT activate 2FA yet.
  3. `POST /api/Auth/2fa/verify`: Body `{ "code": "123456" }`. Activates 2FA upon valid TOTP.
  4. `POST /api/Auth/2fa/disable`: Body `{ "code": "123456" }`. Deactivates 2FA upon valid TOTP.
- **Error Handling**: Follows RFC 7807 problem details (`ApiException`), handling 400 Bad Request (invalid code), 401 Unauthorized, and rate limiting.

### 4. Navigation & Architecture
- **Navigation**:
  - `HomeScreen` AppBar receives a Security/Settings action button (`Icons.security_outlined`).
  - Route `/security-settings` / `/two-factor-settings` hosts the 2FA status card and setup wizard.
- **State Management**:
  - `TwoFactorCubit` managing states:
    - `TwoFactorInitial`
    - `TwoFactorLoading`
    - `TwoFactorStatusLoaded(bool isEnabled)`
    - `TwoFactorSetupInProgress(String secret, String qrCodeUri)`
    - `TwoFactorSuccess(String message, bool isEnabled)`
    - `TwoFactorFailure(String error)`
