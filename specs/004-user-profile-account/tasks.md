# Tasks: FEAT-04 — User Profile & Account Management

**Branch**: `004-user-profile-account` | **Spec**: [specs/004-user-profile-account/spec.md](spec.md) | **Plan**: [specs/004-user-profile-account/plan.md](plan.md)

---

## Phase 1: Setup & Constants

**Purpose**: Register new endpoint constants and route names.

- [ ] T001 [P] Add `changePassword = '/api/Auth/change-password'` to `lib/core/constants/api_constants.dart`
- [ ] T002 [P] Add `profile = '/profile'` to `lib/core/router/route_names.dart`

---

## Phase 2: Foundational (Data Layer & Contracts)

**Purpose**: Core DTOs, data source methods, and repository contracts for profile, password change, and account deletion.

- [ ] T003 [P] Create `ChangePasswordRequest` in `lib/features/auth/data/models/change_password_request.dart`
- [ ] T004 [P] Create `DeleteAccountRequest` in `lib/features/auth/data/models/delete_account_request.dart`
- [ ] T005 Update `AuthRemoteDataSource` interface with `changePassword` and `deleteAccount` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [ ] T006 Implement `changePassword` and `deleteAccount` in `AuthRemoteDataSourceImpl` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [ ] T007 Update `AuthRepository` interface with `getProfile`, `changePassword`, `deleteAccount` in `lib/features/auth/domain/repositories/auth_repository.dart`
- [ ] T008 Implement `getProfile`, `changePassword`, `deleteAccount` in `AuthRepositoryImpl` in `lib/features/auth/data/repositories/auth_repository_impl.dart`

---

## Phase 3: State Management (Cubits)

**Purpose**: Reactive state machines for profile loading, password change form, and account deletion.

- [ ] T009 Define `ProfileState` and `ProfileCubit` in `lib/features/auth/presentation/cubits/profile_cubit.dart` & `profile_state.dart`
- [ ] T010 Define `ChangePasswordState` and `ChangePasswordCubit` in `lib/features/auth/presentation/cubits/change_password_cubit.dart` & `change_password_state.dart`

---

## Phase 4: User Story 1 - Kullanıcı Profil Bilgilerini Görüntüleme (Priority: P1)

**Goal**: Allow authenticated user to view their email, user ID (with copy to clipboard), role badge, and 2FA status.

- [ ] T011 [US1] Create `ProfileScreen` in `lib/features/auth/presentation/screens/profile_screen.dart` with identity card, copyable User ID, and role badge
- [ ] T012 [US1] Register `/profile` route in `lib/core/router/app_router.dart`
- [ ] T013 [US1] Add Account/Profile icon in `HomeScreen` AppBar navigating to `/profile`

---

## Phase 5: User Story 2 - Oturum Açıkken Şifre Değiştirme (Priority: P1)

**Goal**: Allow user to update password using current password and new password with validation.

- [ ] T014 [US2] Implement Change Password card/modal in `ProfileScreen` with current, new, and confirm password fields
- [ ] T015 [US2] Implement real-time client-side password validation (min 8 chars, uppercase, digit, special char, match)
- [ ] T016 [US2] Connect password form to `ChangePasswordCubit.submit` and show success feedback

---

## Phase 6: User Story 3 - Hesabı Kalıcı Olarak Silme (Priority: P2)

**Goal**: Allow user to permanently delete their account with password confirmation.

- [ ] T017 [US3] Create destructive confirmation dialog for account deletion requiring password input in `ProfileScreen`
- [ ] T018 [US3] Connect dialog confirmation to `ProfileCubit.deleteAccount`
- [ ] T019 [US3] Implement post-deletion teardown: clear local storage via `SecureStorageService`, trigger `LoggedOut` on `AuthBloc`, redirect to `/login`

---

## Phase 7: Polish & Verification

**Purpose**: End-to-end testing, error handling, and lint verification.

- [ ] T020 Run `flutter analyze` to verify zero static analysis errors or warnings
- [ ] T021 Run `flutter test` to ensure existing unit tests pass
- [ ] T022 Test full profile, password change, and account deletion lifecycle on device per `specs/004-user-profile-account/quickstart.md`
