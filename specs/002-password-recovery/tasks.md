# Tasks: FEAT-02 — Password Recovery & Deep Linking

**Input**: Design documents from `specs/002-password-recovery/` (`spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`)  
**Status**: Ready for implementation  

---

## Phase 1: Setup & Constants

**Purpose**: Define endpoints, routes, and platform deep link intent configurations.

- [ ] T001 Add `forgotPassword` (`/api/Auth/forgot-password`) and `resetPassword` (`/api/Auth/reset-password`) constants in `lib/core/constants/api_constants.dart`
- [ ] T002 [P] Add `forgotPassword` (`/forgot-password`) and `resetPassword` (`/reset-password`) route constants in `lib/core/router/route_names.dart`
- [ ] T003 [P] Add deep link intent filters for `todoapp://reset-password` and `https://todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net/reset-password` in `android/app/src/main/AndroidManifest.xml`
- [ ] T004 [P] Add custom URL scheme `todoapp` in `ios/Runner/Info.plist` under `CFBundleURLTypes`

---

## Phase 2: Foundational (Data Models & Core Networking)

**Purpose**: Core DTOs, repository interfaces, and data sources required by all user stories.

- [ ] T005 [P] Create `ForgotPasswordRequest` model with `email` field in `lib/features/auth/data/models/forgot_password_request.dart`
- [ ] T006 [P] Create `ResetPasswordRequest` model with `token` and `newPassword` fields in `lib/features/auth/data/models/reset_password_request.dart`
- [ ] T007 [P] Create `AuthMessageResponseDto` model with `message` string field in `lib/features/auth/data/models/auth_message_response_dto.dart`
- [ ] T008 Add `forgotPassword(String email)` and `resetPassword(String token, String newPassword)` method signatures in `lib/features/auth/domain/repositories/auth_repository.dart`
- [ ] T009 Implement `forgotPassword` and `resetPassword` API calls in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [ ] T010 Implement `forgotPassword` and `resetPassword` methods with RFC 7807 `ApiException` to `ServerFailure` mapping in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] T011 Register `/forgot-password` and `/reset-password` route configurations in `lib/core/router/app_router.dart`

---

## Phase 3: User Story 1 - Şifremi Unuttum Bağlantısı İsteme (Priority: P1) ⭐ MVP

**Goal**: Unauthenticated user can request a password recovery email with 60s cooldown timer and generic success feedback.

**Independent Test**: Navigate to `/forgot-password`, enter valid email, tap "Sıfırlama Bağlantısı Gönder". Observe success message and 60-second visual countdown on the button.

- [ ] T012 [P] [US1] Create `ForgotPasswordState` with `email`, `emailError`, `cooldownSeconds`, `successMessage`, `generalError` in `lib/features/auth/presentation/cubits/forgot_password_state.dart`
- [ ] T013 [US1] Create `ForgotPasswordCubit` with email validation, 60s `Timer.periodic` cooldown timer, and submit handling in `lib/features/auth/presentation/cubits/forgot_password_cubit.dart`
- [ ] T014 [US1] Implement `ForgotPasswordScreen` with email field, 60s countdown on submit button, and generic info message in `lib/features/auth/presentation/screens/forgot_password_screen.dart`
- [ ] T015 [US1] Add "Şifremi Unuttum" link button to `lib/features/auth/presentation/screens/login_screen.dart` navigating to `RouteNames.forgotPassword`

---

## Phase 4: User Story 2 - Derin Bağlantı (Deep Link) ile Şifre Sıfırlama Ekranına Ulaşma (Priority: P1)

**Goal**: App automatically opens from email link (`todoapp://reset-password?token=...` or web URL), extracts and URL-decodes token, and navigates to reset screen.

**Independent Test**: Trigger deep link via ADB command `adb shell am start -a android.intent.action.VIEW -d "todoapp://reset-password?token=TEST_TOKEN_123" com.example.todo_app_mobile`. Verify app opens and lands on `/reset-password` with token populated.

- [ ] T016 [US2] Implement token query parameter extraction and character-safe `Uri.decodeComponent` in `lib/core/router/app_router.dart` for `/reset-password`
- [ ] T017 [US2] Add empty or malformed token guard in `lib/core/router/app_router.dart` redirecting to `/login` with an error SnackBar if token is absent

---

## Phase 5: User Story 3 - Yeni Şifre Belirleme ve Girişe Yönlendirme (Priority: P1)

**Goal**: User sets a new password meeting security rules (8+ chars, upper, digit, special), submits with decoded token, and is redirected to login with pre-filled email.

**Independent Test**: On `/reset-password`, enter valid matching passwords, submit. Verify password is reset, redirected to `/login` with email pre-filled and success SnackBar shown.

- [ ] T018 [P] [US3] Create `ResetPasswordState` with `token`, `newPassword`, `confirmPassword`, field errors, `generalError` in `lib/features/auth/presentation/cubits/reset_password_state.dart`
- [ ] T019 [US3] Create `ResetPasswordCubit` with password validation regex (min 8 chars, 1 uppercase, 1 digit, 1 special char), match check, and submit logic in `lib/features/auth/presentation/cubits/reset_password_cubit.dart`
- [ ] T020 [US3] Implement `ResetPasswordScreen` UI with password fields, real-time validation error display, and submit button in `lib/features/auth/presentation/screens/reset_password_screen.dart`
- [ ] T021 [US3] Implement success navigation in `ResetPasswordScreen` redirecting to `RouteNames.login` passing `email` in extra payload
- [ ] T022 [US3] Update `LoginScreen` to extract `extra['email']` and populate `LoginCubit` state on arrival in `lib/features/auth/presentation/screens/login_screen.dart`

---

## Phase 6: User Story 4 - Süresi Dolmuş veya Geçersiz Belirteç Yönetimi (Priority: P2)

**Goal**: User attempting to reset with expired or invalid token receives clear error feedback and a "Yeni Bağlantı İste" button navigating to `/forgot-password`.

**Independent Test**: Submit reset request with invalid token. Verify 400 Problem Details error is displayed and "Yeni Bağlantı İste" button redirects to `/forgot-password`.

- [ ] T023 [US4] Map expired/invalid token server errors in `ResetPasswordCubit` to `ResetPasswordFailure` state with actionable message in `lib/features/auth/presentation/cubits/reset_password_cubit.dart`
- [ ] T024 [US4] Display "Yeni Bağlantı İste" action button in `ResetPasswordScreen` when token error occurs, redirecting user to `RouteNames.forgotPassword` in `lib/features/auth/presentation/screens/reset_password_screen.dart`

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Format code, analyze for static issues, and execute validation scenarios.

- [ ] T025 [P] Clean up unused imports and run `dart format .` on the entire project
- [ ] T026 Run `flutter analyze` to ensure zero errors and zero warnings
- [ ] T027 Execute manual validation scenarios in `specs/002-password-recovery/quickstart.md` (Forgot password cooldown & ADB deep link test)

---

## Dependencies & Execution Order

### Phase Dependencies
- **Phase 1 (Setup & Constants)**: No dependencies — start immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1 completion — blocks all user stories.
- **Phase 3 (User Story 1 - Forgot Password)**: Can start after Phase 2 — MVP milestone.
- **Phase 4 (User Story 2 - Deep Link)**: Depends on Phase 2.
- **Phase 5 (User Story 3 - Reset Password)**: Depends on Phase 4 (needs deep link route) and Phase 2.
- **Phase 6 (User Story 4 - Error Handling & Recovery)**: Depends on Phase 5.
- **Phase 7 (Polish)**: Runs after all user stories are complete.

### Parallel Opportunities
- T002, T003, T004 in Phase 1 can be developed in parallel.
- T005, T006, T007 in Phase 2 can be developed in parallel.
- T012 and T018 (States) can be developed in parallel.
- Once Phase 2 is complete, US1 (Phase 3) and US2 (Phase 4) can proceed in parallel.

---

## Implementation Strategy: MVP First

1. **Step 1**: Complete Phase 1 & 2 (Setup, DTOs, API & Router infrastructure).
2. **Step 2**: Complete Phase 3 (US1 - Forgot password screen with 60s cooldown). **STOP & TEST MVP**.
3. **Step 3**: Complete Phase 4 (US2 - Deep link integration).
4. **Step 4**: Complete Phase 5 (US3 - Reset password form & pre-filled login redirect).
5. **Step 5**: Complete Phase 6 (US4 - Expired token recovery).
6. **Step 6**: Complete Phase 7 (Polish, format, analyze).
