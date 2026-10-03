# Implementation Plan: FEAT-04 — User Profile & Account Management

**Branch**: `004-user-profile-account` | **Date**: 2026-10-03 | **Spec**: [specs/004-user-profile-account/spec.md](spec.md)

**Input**: Feature specification from `specs/004-user-profile-account/spec.md`

---

## Summary

Deliver complete User Profile & Account Management for authenticated users in the TodoApp Flutter mobile client. The solution enables users to view their identity and role (`GET /api/Users/me`), change their password while logged in (`PUT /api/Auth/change-password`), and permanently delete their account with password confirmation (`DELETE /api/Users/me`), followed by local credential erasure and automated redirect to the login screen.

The implementation strictly honors the project Constitution: Clean Architecture with Feature-First organization under `lib/features/auth/` (and profile views), Flutter Bloc/Cubit for reactive state management, Dio for HTTP communication with bearer authentication, GoRouter for navigation, and RFC 7807 problem details parsing.

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (stable channel)  
**Primary Dependencies**: `flutter_bloc` (^9.1.1), `dio` (^5.11.1), `go_router` (^18.0.2), `equatable` (^3.0.0)  
**Storage**: Secure Storage (credential purge via `SecureStorageService.clearAuthData()` upon account deletion)  
**Testing**: `flutter_test`, `bloc_test`, `mocktail`  
**Target Platform**: Android (API 21+) and iOS (iOS 13+)  
**Project Type**: Mobile Application (Consumer client consuming existing .NET Web API)  
**Performance Goals**: Profile fetch < 1s; form validation < 50ms; deletion teardown < 1s  
**Constraints**: Account deletion is irreversible; password change requires current password; RFC 7807 error parsing  
**Scale/Scope**: 3 API endpoints (`GET /api/Users/me`, `PUT /api/Auth/change-password`, `DELETE /api/Users/me`); 1 new screen (`ProfileScreen`); AppBar link in `HomeScreen`  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Requirement | Plan Alignment | Status |
|:---|:---|:---|:---:|
| **I. API-First Consumer** | Consume existing API without backend modifications | Strictly consumes `/api/Users/me` (GET & DELETE) and `/api/Auth/change-password` (PUT) as defined in `docs/spec.md`. | **PASS** |
| **II. Feature-Isolated Architecture** | Clean Architecture layers | Integrates cleanly into auth feature (`lib/features/auth/`) data, domain, and presentation layers. | **PASS** |
| **III. Bloc-Driven State Management** | Immutable states and Equatable | `ProfileCubit` and `ChangePasswordCubit` manage profile display, password form validation, and account deletion. | **PASS** |
| **IV. Dio-Powered Network Layer** | Centralized Dio with error parsing | Uses centralized `DioClient` with Bearer auth; handles 204 No Content responses and RFC 7807 problem details via `ApiException`. | **PASS** |
| **V. Secure Token Lifecycle** | No plain-text leaks; full teardown | On account deletion, `clearAuthData()` purges all tokens from secure storage and `AuthBloc` transitions to `Unauthenticated`. | **PASS** |
| **VI. Spec-Driven Development** | Follow specify → plan → tasks → implement workflow | Executing `/speckit-plan`; specification and design artifacts complete. | **PASS** |
| **VII. Simplicity & YAGNI** | Avoid over-engineering | Reuses existing `UserProfileResponseDto` and `AuthTextField` widgets without new third-party packages. | **PASS** |

---

## Project Structure

### Documentation (this feature)

```text
specs/004-user-profile-account/
├── spec.md              # Feature specification
├── plan.md              # Implementation plan (this file)
├── research.md          # Technical decisions and design analysis
├── data-model.md        # Entities, DTOs, and Cubit states
├── contracts/           # API JSON schema contracts
│   └── profile-account-endpoints.json
├── quickstart.md        # Step-by-step verification guide
└── tasks.md             # Implementation tasks
```

### Source Code Changes

```text
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart             # Add changePassword endpoint
│   └── router/
│       ├── app_router.dart                # Add /profile route
│       └── route_names.dart               # Add profile constant
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   └── auth_remote_data_source.dart   # Add changePassword and deleteAccount
        │   ├── models/
        │   │   ├── change_password_request.dart
        │   │   └── delete_account_request.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   └── repositories/
        │       └── auth_repository.dart           # Declare changePassword & deleteAccount
        └── presentation/
            ├── cubits/
            │   ├── profile_cubit.dart             # Profile data & account deletion
            │   ├── profile_state.dart
            │   ├── change_password_cubit.dart     # Password change form state
            │   └── change_password_state.dart
            └── screens/
                ├── home_screen.dart               # Add Profile icon in AppBar
                └── profile_screen.dart            # Identity card, change password form, delete dialog
```
