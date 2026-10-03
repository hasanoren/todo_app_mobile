# Phase 0 Research: User Profile & Account Management (FEAT-04)

## Objective
Provide authenticated users with full visibility into their account identity, role, and security settings, along with the ability to change their password securely and execute permanent, password-verified account deletion.

## Key Technical Decisions

### 1. Unified Profile & Security Navigation
- **Decision**: Add an Account/Profile icon (`Icons.account_circle_outlined`) in `HomeScreen`'s AppBar leading to `/profile` (`ProfileScreen`).
- **Rationale**: Groups identity information (`email`, `userId`, `role`), security actions (link to `TwoFactorScreen`, "Şifre Değiştir"), and danger actions ("Hesabımı Sil") in a single, intuitive settings hub.

### 2. Password Change Handshake (`PUT /api/Auth/change-password`)
- **Decision**: Present a clean modal bottom sheet or collapsible card for "Şifre Değiştir".
- **Fields**: `currentPassword`, `newPassword`, `confirmPassword`.
- **Validation**:
  - `currentPassword`: cannot be empty.
  - `newPassword`: must satisfy min 8 chars, 1 uppercase, 1 digit, 1 special character.
  - `confirmPassword`: must strictly match `newPassword`.
- **Response**: The API returns `204 No Content` on success. The client displays a success snackbar and resets the password form fields.

### 3. Account Deletion & Post-Deletion Teardown (`DELETE /api/Users/me`)
- **Decision**: Trigger a destructive `AlertDialog` warning the user that deletion is irreversible and will delete all todo items, lists, and account history.
- **Confirmation**: Require entering the current account password to prevent unauthorized or accidental clicks.
- **Teardown**: Upon receiving `204 No Content`:
  1. Call `SecureStorageService.clearAuthData()`.
  2. Dispatch `LoggedOut()` to `AuthBloc`.
  3. `AppRouter`'s redirect guard immediately routes to `/login`.
  4. Display a confirmation snackbar: *"Hesabınız ve ilişkili tüm veriler kalıcı olarak silindi."*

### 4. Role-Based Badging
- **Decision**: Display a styled chip/badge for the user's role (`User` vs `Admin`).
- **Rationale**: Provides clear visibility into account privileges, paving the way for FEAT-08 (Tags & Categorization, where Admin has tag creation privileges).
