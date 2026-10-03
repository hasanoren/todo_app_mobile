# Implementation Plan: FEAT-02 — Password Recovery & Deep Linking

**Branch**: `002-password-recovery` | **Date**: 2026-10-03 | **Spec**: [specs/002-password-recovery/spec.md](spec.md)

**Input**: Feature specification from `specs/002-password-recovery/spec.md`

---

## Summary

Deliver a complete password recovery and deep linking capability for the TodoApp Flutter mobile client. The solution enables unauthenticated users who forgot their credentials to request a recovery email (`POST /api/Auth/forgot-password`), securely capture the incoming reset token via mobile deep link (`todoapp://reset-password?token=...` and universal link), safely URL-decode the token, set a new password complying with security rules (`POST /api/Auth/reset-password`), and seamlessly transition to the Login screen with their email pre-filled.

The implementation strictly honors the project Constitution: Clean Architecture with Feature-First organization under `lib/features/auth/`, Flutter Bloc/Cubit for form state management, Dio for HTTP communication, GoRouter for deep link route handling, and zero unneeded third-party libraries.

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (stable channel)  
**Primary Dependencies**: `flutter_bloc` (^9.0.0), `dio` (^5.8.0), `go_router` (^14.8.0), `equatable` (^2.0.7)  
**Storage**: In-memory (transient reset session)  
**Testing**: `flutter_test`, `bloc_test`, `mocktail` for unit testing cubits and data sources  
**Target Platform**: Android (API 21+) and iOS (iOS 13+)  
**Project Type**: Mobile Application (Consumer client consuming existing .NET Web API)  
**Performance Goals**: Deep link launch to reset screen display < 2s; request feedback < 1s; client validation < 100ms  
**Constraints**: Character-safe URL decoding of token; 2/min rate limit handled proactively via 60s cooldown timer; RFC 7807 problem details parsing for error handling  
**Scale/Scope**: 2 endpoints (`/api/Auth/forgot-password`, `/api/Auth/reset-password`); 2 new screens (`ForgotPasswordScreen`, `ResetPasswordScreen`); Android & iOS deep link intent configuration  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Requirement | Plan Alignment | Status |
|:---|:---|:---|:---:|
| **I. API-First Consumer** | Consume existing API without backend modifications | Strictly consumes `POST /api/Auth/forgot-password` and `POST /api/Auth/reset-password` as defined in `docs/spec.md`. | **PASS** |
| **II. Feature-Isolated Architecture** | Feature lives under `lib/features/<name>/` with Clean Architecture layers | Password recovery belongs to the Auth domain and cleanly extends `lib/features/auth/` (`data`, `domain`, `presentation`). | **PASS** |
| **III. Bloc-Driven State Management** | Event-driven with immutable states and Equatable | `ForgotPasswordCubit` and `ResetPasswordCubit` manage UI form states, cooldown timer, and error tracking. | **PASS** |
| **IV. Dio-Powered Network Layer** | Centralized Dio with error parsing | Uses centralized `DioClient` and parses RFC 7807 errors through existing `ApiException` and `Failure` models. | **PASS** |
| **V. Secure Token Lifecycle** | No plain-text or persistent leaks | Reset token is transient (in-memory only) and discarded immediately after use or navigation. | **PASS** |
| **VI. Spec-Driven Development** | Follow specify → plan → tasks → implement workflow | Currently executing `/speckit-plan`; specification verified and design artifacts completed. | **PASS** |
| **VII. Simplicity & YAGNI** | Avoid over-engineering and unneeded dependencies | Uses native `GoRouter` URI parsing and native platform intent filters without adding third-party deep link packages. | **PASS** |

---

## Project Structure

### Documentation (this feature)

```text
specs/002-password-recovery/
├── spec.md              # Feature specification
├── plan.md              # Implementation plan (this file)
├── research.md          # Technical decisions and deep link research
├── data-model.md        # Entities, DTOs, and Cubit states
├── contracts/           # API JSON schema contracts
│   └── password-recovery-endpoints.json
├── quickstart.md        # Manual and automated verification scenarios
└── checklists/          # Requirements completeness checklist
    └── requirements.md
```

### Source Code Touchpoints

```text
android/app/src/main/
└── AndroidManifest.xml                        # Deep link intent filters (todoapp:// and https://)

ios/Runner/
└── Info.plist                                 # CFBundleURLTypes custom URL scheme (todoapp)

lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart                 # Add forgotPassword & resetPassword paths
│   └── router/
│       ├── route_names.dart                   # Add forgotPassword & resetPassword routes
│       └── app_router.dart                    # Configure /forgot-password & /reset-password routes
│
└── features/auth/
    ├── data/
    │   ├── datasources/
    │   │   └── auth_remote_data_source.dart   # Add forgotPassword & resetPassword calls
    │   ├── models/
    │   │   ├── forgot_password_request.dart   # Request body model
    │   │   ├── reset_password_request.dart    # Request body model
    │   │   └── auth_message_response_dto.dart # Response message DTO
    │   └── repositories/
    │       └── auth_repository_impl.dart      # Implement forgotPassword & resetPassword
    ├── domain/
    │   └── repositories/
    │       └── auth_repository.dart           # Declare repository contract methods
    └── presentation/
        ├── cubits/
        │   ├── forgot_password_cubit.dart     # Cooldown timer & request handling
        │   ├── forgot_password_state.dart     # Cooldown & validation state
        │   ├── reset_password_cubit.dart      # Password rule checks & reset submission
        │   └── reset_password_state.dart      # Validation & submission state
        └── screens/
            ├── forgot_password_screen.dart    # UI: Email input + cooldown timer button
            ├── reset_password_screen.dart     # UI: New password + confirmation + submit
            └── login_screen.dart              # Update to consume pre-filled email from extra
```

**Structure Decision**: Fully aligns with existing Clean Architecture and Feature-First structure under `lib/features/auth/`. Reuses existing widgets (`AuthTextField`, `AuthPrimaryButton`).

---

## Complexity Tracking

*No constitution violations. Zero added dependencies.*
