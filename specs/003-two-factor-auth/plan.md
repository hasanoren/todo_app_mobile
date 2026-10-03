# Implementation Plan: FEAT-03 — Two-Factor Authentication Management

**Branch**: `003-two-factor-auth` | **Date**: 2026-10-03 | **Spec**: [specs/003-two-factor-auth/spec.md](spec.md)

**Input**: Feature specification from `specs/003-two-factor-auth/spec.md`

---

## Summary

Deliver complete Two-Factor Authentication (2FA) lifecycle management for authenticated users in the TodoApp Flutter mobile client. The solution enables logged-in users to view their current 2FA status, initiate TOTP-based 2FA setup (`POST /api/Auth/2fa/enable`), view a rendered QR code along with a copyable manual secret key, confirm activation using a 6-digit TOTP code (`POST /api/Auth/2fa/verify`), and disable 2FA securely by confirming their current TOTP code (`POST /api/Auth/2fa/disable`).

The implementation strictly honors the project Constitution: Clean Architecture with Feature-First organization extending `lib/features/auth/`, Flutter Bloc/Cubit for reactive state management, Dio for HTTP communication with bearer authentication, GoRouter for navigation, and `qr_flutter` for native canvas-based QR rendering.

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (stable channel)  
**Primary Dependencies**: `flutter_bloc` (^9.1.1), `dio` (^5.11.1), `go_router` (^18.0.2), `equatable` (^3.0.0), `qr_flutter` (^4.1.0)  
**Storage**: Secure Storage (existing JWT access token for authenticated API requests)  
**Testing**: `flutter_test`, `bloc_test`, `mocktail`  
**Target Platform**: Android (API 21+) and iOS (iOS 13+)  
**Project Type**: Mobile Application (Consumer client consuming existing .NET Web API)  
**Performance Goals**: QR Code rendering < 100ms; verification response < 1s; clipboard copy feedback < 50ms  
**Constraints**: 2FA activation requires 2-step handshake (verify must succeed before status becomes active); disabling requires valid TOTP code; RFC 7807 problem details parsing  
**Scale/Scope**: 4 API endpoints (`GET /api/Users/me`, `POST /api/Auth/2fa/enable`, `POST /api/Auth/2fa/verify`, `POST /api/Auth/2fa/disable`); 1 new management screen (`TwoFactorScreen`); AppBar navigation link from `HomeScreen`  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Requirement | Plan Alignment | Status |
|:---|:---|:---|:---:|
| **I. API-First Consumer** | Consume existing API without backend modifications | Strictly consumes existing endpoints from `docs/spec.md`: `/api/Users/me`, `/api/Auth/2fa/enable`, `/api/Auth/2fa/verify`, `/api/Auth/2fa/disable`. | **PASS** |
| **II. Feature-Isolated Architecture** | Feature lives under `lib/features/<name>/` with Clean Architecture layers | 2FA management belongs to Auth and cleanly extends `lib/features/auth/` (`data`, `domain`, `presentation`). | **PASS** |
| **III. Bloc-Driven State Management** | Event-driven with immutable states and Equatable | `TwoFactorCubit` manages 2FA status, setup data (QR code / secret), verification, and error handling. | **PASS** |
| **IV. Dio-Powered Network Layer** | Centralized Dio with error parsing | Uses centralized `DioClient` with Bearer auth token and parses RFC 7807 problem details via `ApiException`. | **PASS** |
| **V. Secure Token Lifecycle** | No plain-text or persistent leaks | Secret key and TOTP codes are ephemeral in memory and cleared on completion or screen disposal. | **PASS** |
| **VI. Spec-Driven Development** | Follow specify → plan → tasks → implement workflow | Executing `/speckit-plan`; specification verified and design artifacts completed. | **PASS** |
| **VII. Simplicity & YAGNI** | Avoid over-engineering and unneeded dependencies | Uses lightweight `qr_flutter` (pure Dart canvas painter, no native bloat) and built-in Flutter `Clipboard`. | **PASS** |

---

## Project Structure

### Documentation (this feature)

```text
specs/003-two-factor-auth/
├── spec.md              # Feature specification & user clarifications
├── plan.md              # Implementation plan (this file)
├── research.md          # Technical decisions and QR/TOTP research
├── data-model.md        # Entities, DTOs, and Cubit states
├── contracts/           # API JSON schema contracts
│   └── two-factor-endpoints.json
├── quickstart.md        # Step-by-step verification guide
└── tasks.md             # Implementation tasks (created in next step)
```

### Source Code Changes

```text
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart             # Add 2FA endpoints and /api/Users/me
│   └── router/
│       ├── app_router.dart                # Add /two-factor-settings route
│       └── route_names.dart               # Add twoFactorSettings constant
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   ├── auth_remote_data_source.dart   # Add enable2fa, verify2fa, disable2fa, getProfile
        │   │   └── auth_remote_data_source_impl.dart
        │   ├── models/
        │   │   ├── two_factor_enable_response_dto.dart
        │   │   ├── two_factor_verify_request.dart
        │   │   ├── two_factor_disable_request.dart
        │   │   └── user_profile_response_dto.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   └── repositories/
        │       └── auth_repository.dart           # Declare 2FA contracts
        └── presentation/
            ├── cubits/
            │   ├── two_factor_cubit.dart          # Manages 2FA lifecycle states
            │   └── two_factor_state.dart
            └── screens/
                ├── home_screen.dart               # Add Security icon in AppBar
                └── two_factor_screen.dart         # Status card, QR Code, Secret copy, TOTP verification modal
```
