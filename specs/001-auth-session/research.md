# Technical Research: Authentication & Session Lifecycle

**Feature**: FEAT-01 (Authentication & Session Lifecycle)  
**Date**: 2026-10-02  
**Status**: Completed  

---

## 1. Network Layer & Mutex-Protected Token Refresh (Dio)

### Decision
Use **Dio** with a dedicated `QueuedInterceptor` (or custom lock mechanism) for token refresh.

### Rationale
- When an access token expires (60-minute lifetime), multiple parallel HTTP requests may simultaneously receive a `401 Unauthorized`.
- A naive interceptor would trigger multiple parallel calls to `POST /api/Auth/refresh`. Because refresh tokens are **single-use and immediately revoked**, the first refresh would succeed and all subsequent parallel refresh requests would fail, causing unexpected logouts.
- Dio's `QueuedInterceptor` or a mutex lock holds incoming and failed requests in a queue while a single refresh request executes, then replays all queued requests with the newly acquired JWT access token.
- A secondary, clean Dio instance (without the token refresh interceptor) is used specifically for the refresh request itself to avoid recursive interceptor loops.

### Alternatives Considered
- `http` package: Does not support interceptors natively; requires custom wrapper around every client call and complex manual queuing. Rejected per Constitution Principle IV.
- `Chopper` / `Retrofit`: Heavy abstractions requiring build_runner boilerplate without solving the concurrent refresh problem more cleanly than Dio interceptors.

---

## 2. Secure Token Storage (flutter_secure_storage)

### Decision
Use **`flutter_secure_storage`** to persist `access_token`, `refresh_token`, and basic session metadata (`userId`, `email`).

### Rationale
- Tokens must never be stored in plain text (`SharedPreferences` or local JSON files) due to extraction risks on rooted/jailbroken devices.
- `flutter_secure_storage` uses **Keychain** on iOS and **EncryptedSharedPreferences / KeyStore** on Android.
- Provides simple async `read`, `write`, `delete`, and `deleteAll` operations.
- Fits the logout requirement: `deleteAll()` cleanly wipes all stored credentials.

### Alternatives Considered
- `shared_preferences`: Plain text storage; rejected per Constitution Principle V.
- `hive` with encryption: Requires managing and persisting an encryption key, creating a bootstrapping problem. Keychain/Keystore via `flutter_secure_storage` is the industry standard.

---

## 3. State Management & Session Lifecycle (Flutter Bloc)

### Decision
Use **`flutter_bloc`** with an `AuthBloc` managing global authentication state and a separate `LoginBloc` / `RegisterBloc` managing ephemeral form UI state.

### Rationale
- `AuthBloc` represents the global session state with 4 distinct states:
  1. `AuthInitial`: App launching, checking stored tokens.
  2. `Unauthenticated`: No valid tokens, user must log in.
  3. `AuthTwoFactorRequired`: Temporary 2FA token active, awaiting 6-digit TOTP code.
  4. `Authenticated`: Active session with valid tokens and user identity.
- Clean separation: `AuthBloc` lives at the root of the widget tree (above `MaterialApp.router`) so navigation and guards can react immediately to session changes.
- Form validation, loading spinners, and field-level error display for login and register forms are handled in feature-specific blocs/cubits (`LoginCubit`, `RegisterCubit`), preventing global state pollution.

### Alternatives Considered
- `ChangeNotifier` / `Provider`: Lacks strict state machine transitions and event auditability; easy to introduce race conditions during 2FA challenge and token refresh.
- `Riverpod`: Powerful, but project Constitution Principle III mandates Flutter Bloc.

---

## 4. Declarative Routing & Authentication Guard (GoRouter)

### Decision
Use **`go_router`** with `redirect` logic listening directly to `AuthBloc.stream`.

### Rationale
- `GoRouter.redirect` inspects the current location (`state.matchedLocation`) and the authentication state from `AuthBloc`:
  - If state is `Unauthenticated` and user tries to access a protected route (e.g. `/`, `/tasks`), redirect to `/login`.
  - If state is `AuthTwoFactorRequired`, redirect to `/login/2fa`.
  - If state is `Authenticated` and user is on `/login`, `/register`, or `/login/2fa`, redirect to `/` (home).
- Supports deep linking out-of-the-box (`reset-password?token=...` for FEAT-02).
- Native support for sub-routes: `/login`, `/register`, `/login/2fa`.

### Alternatives Considered
- Flutter Navigator 2.0 (vanilla): Extremely verbose, requires manual page stack management and route parser implementation.
- `auto_route`: Requires extensive code generation (`build_runner`); `go_router` is the official Google solution and approved in Constitution.

---

## 5. RFC 7807 Problem Details Error Handling

### Decision
Implement an `ApiException` and `ValidationError` model in `lib/core/network/` that parses RFC 7807 responses.

### Rationale
- The backend returns standardized error responses:
  ```json
  {
    "type": "...",
    "title": "Validation Error",
    "status": 400,
    "detail": "One or more validation errors occurred.",
    "errors": {
      "email": ["Must be a valid email address."],
      "password": ["Minimum 8 characters required."]
    }
  }
  ```
- A centralized parser extracts:
  - `status`: HTTP status code (400, 401, 403, 409, 429, 500).
  - `detail`: General human-readable message.
  - `errors`: `Map<String, List<String>>` for field-specific errors, directly mapped to Flutter `TextFormField.errorText`.
  - Rate limit (429): Returns user-friendly waiting advice.

### Alternatives Considered
- Handling errors ad-hoc in every UI screen: Results in duplicated parsing, inconsistent error messages, and unhandled status codes. Centralized error mapping guarantees consistent Turkish error presentation.
