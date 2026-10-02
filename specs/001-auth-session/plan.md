# Implementation Plan: Authentication & Session Lifecycle

**Branch**: `001-auth-session` | **Date**: 2026-10-02 | **Spec**: [specs/001-auth-session/spec.md](spec.md)

**Input**: Feature specification from `specs/001-auth-session/spec.md`

---

## Summary

Deliver a production-ready authentication and session management layer for the TodoApp Flutter mobile client. The solution implements secure user registration, standard credential login, 2FA challenge resolution, mutex-protected silent token refresh (60-minute JWT lifecycle), graceful session expiry, and secure credential storage using `flutter_secure_storage`. The architecture strictly follows the project Constitution: Clean Architecture with Feature-First organization, Flutter Bloc for event-driven state management, Dio with custom QueuedInterceptors for networking, and GoRouter for declarative authentication guarding.

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (stable channel)  
**Primary Dependencies**: `flutter_bloc` (^9.0.0), `dio` (^5.8.0), `go_router` (^14.8.0), `flutter_secure_storage` (^9.2.4), `equatable` (^2.0.7)  
**Storage**: Platform Keystore / Keychain via `flutter_secure_storage` for credentials  
**Testing**: `flutter_test`, `bloc_test`, `mocktail` for unit and state transition tests  
**Target Platform**: Android (API 21+) and iOS (iOS 13+)  
**Project Type**: Mobile Application (Consumer client consuming existing .NET Web API)  
**Performance Goals**: App startup session check < 2s; token refresh invisible to user; login/register response feedback < 1s  
**Constraints**: Zero plain-text token storage; mutex-locked single-flight token refresh (prevent race-conditioned refresh revocation); RFC 7807 problem details parsing for field validation errors  
**Scale/Scope**: 5 endpoints (`register`, `login`, `login-2fa`, `refresh`, `logout`); 3 UI screens (`LoginScreen`, `RegisterScreen`, `TwoFactorScreen`); 1 root session guard  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Requirement | Plan Alignment | Status |
|:---|:---|:---|:---:|
| **I. API-First Consumer** | Consume existing API without backend modifications | Strictly maps to 5 documented endpoints under base URL `https://todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net` | **PASS** |
| **II. Feature-Isolated Architecture** | Feature lives under `lib/features/<name>/` with Clean Architecture layers | Auth components isolated in `lib/features/auth/` (`data`, `domain`, `presentation`); shared networking and storage in `lib/core/` | **PASS** |
| **III. Bloc-Driven State Management** | Event-driven with immutable states and Equatable | `AuthBloc` manages global session states (`AuthInitial`, `Unauthenticated`, `AuthTwoFactorRequired`, `Authenticated`); `LoginCubit` and `RegisterCubit` manage form UI state | **PASS** |
| **IV. Dio-Powered Network Layer** | Centralized Dio with Auth and Refresh interceptors | Central Dio client in `lib/core/network/` with `AuthInterceptor` and `QueuedInterceptor` for mutex token refresh | **PASS** |
| **V. Secure Token Lifecycle** | Encrypted token storage with proactive refresh | All tokens saved in `flutter_secure_storage`; 55-min pre-emptive refresh and 401 fallback | **PASS** |
| **VI. Spec-Driven Development** | Follow specify → plan → tasks → implement workflow | Currently executing `/speckit-plan`; specification verified and design artifacts completed | **PASS** |
| **VII. Simplicity & YAGNI** | Avoid over-engineering and undocumented protocols | Network-first approach without unneeded offline sync protocols; minimal clean dependencies | **PASS** |

---

## Project Structure

### Documentation (this feature)

```text
specs/001-auth-session/
├── spec.md              # Feature specification & requirements
├── checklists/
│   └── requirements.md  # Quality validation checklist
├── plan.md              # This implementation plan
├── research.md          # Phase 0: Technical decisions & rationale
├── data-model.md        # Phase 1: Entities, DTOs, and state transitions
├── contracts/
│   └── auth-endpoints.json # Phase 1: API contract & JSON schemas
├── quickstart.md        # Phase 1: Validation scenarios & test commands
└── tasks.md             # Phase 2: Actionable task list (generated via /speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # Base URL, endpoints, timeouts
│   │   └── storage_keys.dart        # Secure storage key names
│   ├── network/
│   │   ├── dio_client.dart          # Central Dio instance configuration
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart     # Injects Authorization Bearer header
│   │   │   └── token_refresh_interceptor.dart # Mutex queued 401 refresh
│   │   └── errors/
│   │       ├── api_exception.dart   # RFC 7807 Problem Details parser
│   │       └── failure.dart         # Domain failure abstractions
│   ├── storage/
│   │   └── secure_storage_service.dart # Wrapper around flutter_secure_storage
│   └── router/
│       ├── app_router.dart          # GoRouter setup with AuthBloc redirect
│       └── route_names.dart         # Named route constants (/login, /register, /login/2fa, /)
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── auth_remote_data_source.dart # Direct Dio calls to /api/Auth/*
│       │   ├── models/
│       │   │   ├── auth_response_dto.dart       # JSON serialization for AuthResponse
│       │   │   └── user_dto.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart    # Implements domain AuthRepository
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── auth_session.dart            # Active user session entity
│       │   │   └── two_factor_challenge.dart    # 2FA challenge entity
│       │   └── repositories/
│       │       └── auth_repository.dart         # Abstract contract
│       └── presentation/
│           ├── bloc/
│           │   ├── auth_bloc.dart               # Global session state machine
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           ├── cubits/
│           │   ├── login_cubit.dart             # Form validation & submission state
│           │   ├── register_cubit.dart
│           │   └── two_factor_cubit.dart
│           ├── screens/
│           │   ├── login_screen.dart            # Login form UI
│           │   ├── register_screen.dart         # Register form UI
│           │   └── two_factor_screen.dart       # 6-digit TOTP input UI
│           └── widgets/
│               ├── auth_text_field.dart         # Styled input with validation error display
│               └── auth_primary_button.dart     # Loading state button
│
└── main.dart                                # Bootstraps dependencies & runApp
```

**Structure Decision**: Clean Architecture with Feature-First packaging. All cross-cutting infrastructure (`network`, `storage`, `router`, `errors`) is housed in `lib/core/` for reuse across subsequent features (FEAT-02 through FEAT-13). All authentication-specific logic is isolated inside `lib/features/auth/`.

---

## Complexity Tracking

> **Violations**: None. All architectural decisions strictly conform to the Project Constitution.
