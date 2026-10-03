# Quickstart & Verification Guide: User Profile & Account Management (FEAT-04)

## Prerequisites
1. User is registered and logged into the application.
2. App is running on a physical Android device or emulator.

## Manual Verification Steps

### Step 1: View Profile & Identity
1. From `HomeScreen`, tap the Profile/Account icon in the top AppBar.
2. Verify `ProfileScreen` loads:
   - Your email address is clearly shown.
   - Your user ID is visible with a "Kopyala" button (tap it to verify the clipboard snackbar).
   - Role badge displays "Kullanıcı" (or "Yönetici" if admin).
   - Security section displays 2FA status and a link to 2FA settings.

### Step 2: Change Password
1. In `ProfileScreen`, tap **"Şifre Değiştir"**.
2. Enter:
   - Current password (e.g. `Password123!`).
   - New password (e.g. `NewSecret123!`).
   - Confirm password (e.g. `NewSecret123!`).
3. Tap **"Şifreyi Güncelle"**.
4. Verify:
   - Success snackbar: *"Şifreniz başarıyla değiştirildi."*
   - Log out and log back in using `NewSecret123!` to confirm the update works on the backend.

### Step 3: Delete Account (Destructive Test)
> **Warning**: This permanently removes the account. For testing, create a disposable dummy account first (e.g. `testdelete@example.com`).
1. Log in with the disposable account.
2. Navigate to `ProfileScreen`.
3. In the "Tehlikeli Bölge" section, tap **"Hesabımı Sil"**.
4. Observe the confirmation dialog with strong warning text.
5. Enter the account password and tap **"Kalıcı Olarak Sil"**.
6. Verify:
   - App navigates directly to the `LoginScreen`.
   - Local tokens are wiped from secure storage.
   - Attempting to log in with the deleted account returns an error (`400/401/User not found`).
