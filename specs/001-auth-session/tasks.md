# Tasks: Authentication & Session Lifecycle

**Feature**: FEAT-01 (Authentication & Session Lifecycle)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 [P] Create `lib/core/constants/api_constants.dart` defining base URL (`https://todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net`) and endpoints
- [x] T002 [P] Create `lib/core/constants/storage_keys.dart` defining keys (`auth_access_token`, `auth_refresh_token`, `auth_user_id`, `auth_email`, `auth_token_expires_at`)
- [x] T003 [P] Create `lib/core/router/route_names.dart` defining named routes (`/login`, `/register`, `/login/2fa`, `/`)
- [x] T004 [P] Create `lib/core/errors/failure.dart` defining domain failure abstractions
- [x] T005 [P] Create `lib/core/errors/api_exception.dart` to parse RFC 7807 Problem Details error responses

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T006 [P] Create `lib/core/storage/secure_storage_service.dart` wrapping `flutter_secure_storage`
- [x] T007 [P] Create `lib/core/network/dio_client.dart` configuring central Dio instance
- [x] T008 [P] Create `lib/core/network/interceptors/auth_interceptor.dart` to inject `Authorization: Bearer`
- [x] T009 [P] Create `lib/core/network/interceptors/token_refresh_interceptor.dart` (initial skeleton for queued 401 handling)
- [x] T010 [P] Create `lib/features/auth/domain/entities/auth_session.dart` and `two_factor_challenge.dart`
- [x] T011 [P] Create `lib/features/auth/domain/repositories/auth_repository.dart` abstract contract
- [x] T012 Create global `AuthBloc` (with events and states) in `lib/features/auth/presentation/bloc/`
- [x] T013 Create `lib/core/router/app_router.dart` configuring GoRouter with AuthBloc redirect guard

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Yeni Kullanıcı Kaydı (Priority: P1) ⭐ MVP

**Goal**: Yeni kullanıcının e-posta ve şifre ile hesap oluşturması, otomatik giriş yapması

**Independent Test**: Uygulama açılışında kayıt formunu doldurup başarıyla ana ekrana yönlendirilme

### Implementation for User Story 1

- [x] T014 [P] [US1] Create `AuthResponseDto` and `RegisterRequest` models in `lib/features/auth/data/models/`
- [x] T015 [US1] Implement `register` endpoint call in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T016 [US1] Implement `register` method in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [x] T017 [P] [US1] Create reusable UI widgets: `AuthTextField` and `AuthPrimaryButton` in `lib/features/auth/presentation/widgets/`
- [x] T018 [US1] Create `RegisterCubit` in `lib/features/auth/presentation/cubits/` with strict password validation (min 8 chars, 1 uppercase, 1 number, 1 special char)
- [x] T019 [US1] Implement `RegisterScreen` UI in `lib/features/auth/presentation/screens/register_screen.dart` and wire up to `RegisterCubit` and `AuthBloc`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Standart Giriş (Priority: P1)

**Goal**: Mevcut kullanıcının e-posta ve şifre ile giriş yapması

**Independent Test**: Geçerli kimlik bilgileriyle giriş yapıldığında ana ekrana geçiş

### Implementation for User Story 2

- [x] T020 [P] [US2] Create `LoginRequest` model in `lib/features/auth/data/models/`
- [x] T021 [US2] Implement `login` endpoint call in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T022 [US2] Implement `login` method in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [x] T023 [US2] Create `LoginCubit` in `lib/features/auth/presentation/cubits/` for form validation
- [x] T024 [US2] Implement `LoginScreen` UI in `lib/features/auth/presentation/screens/login_screen.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - 2FA Giriş Doğrulaması (Priority: P2)

**Goal**: 2FA etkinleştirilmiş kullanıcının 6 haneli TOTP kodunu girerek oturum açması

**Independent Test**: Giriş sonrası 2FA ekranının gelmesi ve geçerli kodla ana ekrana geçiş

### Implementation for User Story 3

- [x] T025 [P] [US3] Create `Login2FaRequest` model in `lib/features/auth/data/models/`
- [x] T026 [US3] Implement `login2Fa` endpoint call in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T027 [US3] Implement `login2Fa` method in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [x] T028 [US3] Create `TwoFactorCubit` in `lib/features/auth/presentation/cubits/` for 6-digit TOTP validation (`r'^\d{6}$'`)
- [x] T029 [US3] Implement `TwoFactorScreen` UI in `lib/features/auth/presentation/screens/two_factor_screen.dart`

---

## Phase 6: User Story 4 - Otomatik Oturum Yenileme (Priority: P1)

**Goal**: Erişim belirtecinin süresi dolduğunda (veya yaklaştığında) arka planda kesintisiz token yenileme

**Independent Test**: Token süresi dolduktan sonra korumalı istek atıldığında `401` dönmesi ve interceptor'ın yeni token ile isteği başarıyla tekrarlaması

### Implementation for User Story 4

- [x] T030 [P] [US4] Create `RefreshTokenRequest` model in `lib/features/auth/data/models/`
- [x] T031 [US4] Implement `refresh` endpoint call in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T032 [US4] Implement `refreshToken` method in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [x] T033 [US4] Complete implementation of `lib/core/network/interceptors/token_refresh_interceptor.dart` (QueuedInterceptor logic, mutex lock, retry original request)
- [x] T034 [US4] Ensure 401 unrecoverable refresh failure updates `AuthBloc` to `Unauthenticated` state and shows "Oturumunuzun süresi doldu" message

---

## Phase 7: User Story 5 - Çıkış Yapma (Priority: P2)

**Goal**: Kullanıcının oturumunu sonlandırması ve belirteçlerin temizlenmesi

**Independent Test**: Çıkış yap butonuna tıklandığında giriş ekranına yönlendirme ve güvenli depolamanın silinmesi

### Implementation for User Story 5

- [x] T035 [P] [US5] Create `LogoutRequest` model in `lib/features/auth/data/models/`
- [x] T036 [US5] Implement `logout` endpoint call in `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- [x] T037 [US5] Implement `logout` method in `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [x] T038 [US5] Update `AuthBloc` to handle `LogoutRequested` event (clears secure storage via `deleteAll()`, transitions to `Unauthenticated`)

---

## Phase 8: User Story 6 - Uygulama Yeniden Açılışında Oturum Devamı (Priority: P2)

**Goal**: Uygulama açılışında geçerli token varsa giriş ekranını atlayıp ana ekrana geçme

**Independent Test**: Giriş yaptıktan sonra uygulamayı kapatıp açınca ana ekranın görünmesi

### Implementation for User Story 6

- [x] T039 [US6] Implement `AppStarted` event handling in `AuthBloc` (checks `secure_storage_service.dart` for token and validity)
- [x] T040 [US6] Integrate `AuthBloc` initialization into `main.dart` before `runApp()` to guarantee state resolution before routing

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T041 Review error handling across all form cubits to ensure RFC 7807 `api_exception.dart` messages are correctly displayed on `AuthTextField`s
- [x] T042 [P] Clean up unused imports and run Flutter formatter
- [x] T043 Execute `quickstart.md` manual validation scenarios to verify end-to-end functionality

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - US1 (Registration), US2 (Login), US4 (Token Refresh) are P1 and should be prioritized.
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### Parallel Opportunities
- All [P] tasks in Setup and Foundational phases can be executed in parallel.
- US1, US2, and US4 model/datasource definitions can be written concurrently.
- Reusable UI widgets (T017) can be built independently of bloc logic.

## Phase 9: Convergence

**Purpose**: Fix gaps identified during convergence check between implementation and specification.

- [x] T044 [US1] Fix RegisterScreen to dispatch LoggedIn event upon RegisterSuccess to trigger redirect (partial FR-001)
- [x] T045 [US4] Implement proactive 55-minute background token refresh via Timer in AuthBloc (missing FR-007)
- [x] T046 [US4] Wire TokenRefreshInterceptor's onRefreshFailed callback to AuthBloc to emit SessionExpired and show expiry message (missing FR-017)
- [x] T047 [US5] Add a generic Logout button to the dummy Home screen in AppRouter to enable testing of the logout flow (missing US5 testability)
