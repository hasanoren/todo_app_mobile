# Tasks: FEAT-03 — Two-Factor Authentication Management

**Branch**: `003-two-factor-auth` | **Spec**: [specs/003-two-factor-auth/spec.md](spec.md) | **Plan**: [specs/003-two-factor-auth/plan.md](plan.md)

---

## Phase 1: Setup & Dependencies

**Purpose**: Ensure all required packages and constants are in place.

- [x] T001 Add `qr_flutter: ^4.1.0` dependency to `pubspec.yaml` and verify `flutter pub get`
- [x] T002 [P] Add 2FA and profile endpoints to `lib/core/constants/api_constants.dart`
- [x] T003 [P] Add `/two-factor-settings` route name to `lib/core/router/route_names.dart`

---

## Phase 2: Foundational (Data Layer & Contracts)

**Purpose**: Core DTOs, data sources, and repository contracts required by all user stories.

- [x] T004 [P] Create `TwoFactorEnableResponseDto` in `lib/features/auth/data/models/two_factor_enable_response_dto.dart`
- [x] T005 [P] Create `TwoFactorVerifyRequest` in `lib/features/auth/data/models/two_factor_verify_request.dart`
- [x] T006 [P] Create `TwoFactorDisableRequest` in `lib/features/auth/data/models/two_factor_disable_request.dart`
- [x] T007 [P] Create `UserProfileResponseDto` in `lib/features/auth/data/models/user_profile_response_dto.dart`
- [x] T008 Update `AuthRemoteDataSource` interface with `getProfile`, `enable2fa`, `verify2fa`, `disable2fa` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T009 Implement 2FA methods in `AuthRemoteDataSourceImpl` using `DioClient` with Bearer auth in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T010 Update `AuthRepository` domain interface in `lib/features/auth/domain/repositories/auth_repository.dart`
- [x] T011 Implement 2FA domain methods in `AuthRepositoryImpl` in `lib/features/auth/data/repositories/auth_repository_impl.dart`

---

## Phase 3: State Management (TwoFactorCubit)

**Purpose**: Reactive state machine for 2FA lifecycle (status loading, setup initiation, TOTP verification, and disabling).

- [x] T012 Define immutable states for 2FA in `lib/features/auth/presentation/cubits/two_factor_state.dart`
- [x] T013 Implement `TwoFactorCubit` with `loadStatus`, `initiateSetup`, `verifyCode`, and `disable2fa` in `lib/features/auth/presentation/cubits/two_factor_cubit.dart`

---

## Phase 4: User Story 1 - 2FA Kurulumunu Başlatma & QR Kod Görüntüleme (Priority: P1)

**Goal**: Allow authenticated user to view current 2FA status and start setup to see QR code and copyable secret key.

- [x] T014 [US1] Create `TwoFactorScreen` layout with current status badge (Enabled/Disabled) in `lib/features/auth/presentation/screens/two_factor_screen.dart`
- [x] T015 [US1] Implement QR code rendering using `QrImageView` (`qr_flutter`) in `TwoFactorScreen`
- [x] T016 [US1] Implement manual secret display container with "Panoya Kopyala" (Clipboard) button and feedback snackbar
- [x] T017 [US1] Register `/two-factor-settings` route in `lib/core/router/app_router.dart`
- [x] T018 [US1] Add Security/Settings icon in `HomeScreen` AppBar to navigate to `/two-factor-settings`

---

## Phase 5: User Story 2 - TOTP Kodu ile Doğrulama ve Etkinleştirme (Priority: P1)

**Goal**: Allow user to enter 6-digit TOTP code, verify with backend, and activate 2FA.

- [x] T019 [US2] Add 6-digit TOTP input field with validation (digits only, max 6) in `TwoFactorScreen`
- [x] T020 [US2] Connect "Doğrula ve Etkinleştir" button to `TwoFactorCubit.verifyCode`
- [x] T021 [US2] Handle success: show green confirmation, switch status badge to "Etkin", hide QR setup view
- [x] T022 [US2] Handle error: show RFC 7807 error feedback on invalid or expired TOTP code

---

## Phase 6: User Story 3 - İki Faktörlü Doğrulamayı Devre Dışı Bırakma (Priority: P2)

**Goal**: Allow user with active 2FA to safely disable it by confirming their current 6-digit TOTP code.

- [x] T023 [US3] Create TOTP confirmation dialog for disabling 2FA in `TwoFactorScreen`
- [x] T024 [US3] Connect dialog confirmation to `TwoFactorCubit.disable2fa`
- [x] T025 [US3] Handle disable success: update status badge to "Devre Dışı", show notification
- [x] T026 [US3] Handle disable error: display invalid code error inside dialog

---

## Phase 7: Polish & Verification

**Purpose**: End-to-end testing, error handling, and lint verification.

- [x] T027 Run `flutter analyze` to verify zero static analysis errors or warnings
- [x] T028 Test full 2FA lifecycle on physical device or emulator per `specs/003-two-factor-auth/quickstart.md`
