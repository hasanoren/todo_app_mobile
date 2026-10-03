# Quickstart & Verification Guide: Two-Factor Authentication Management (FEAT-03)

## Prerequisites
1. User is registered and logged into the application.
2. Authenticator app (e.g. Google Authenticator, Microsoft Authenticator, or 2FAS) installed on a device or emulator.

## Manual Verification Steps

### Step 1: Access 2FA Management
1. Launch the app and log in with valid credentials.
2. On `HomeScreen`, tap the Security/Shield icon in the AppBar.
3. Observe the `TwoFactorScreen`:
   - Current status badge displays **"Devre Dışı"** (Disabled) with a neutral/grey icon.
   - Button **"İki Faktörlü Doğrulamayı Etkinleştir"** is visible and enabled.

### Step 2: Initiate 2FA Setup
1. Tap **"İki Faktörlü Doğrulamayı Etkinleştir"**.
2. Observe setup wizard:
   - A scannable QR Code is rendered.
   - The manual secret key is shown in a monospaced container.
   - Tap **"Anahtarı Kopyala"**; verify snackbar confirmation: *"Gizli anahtar panoya kopyalandı"*.

### Step 3: Scan and Verify TOTP
1. Scan the QR code or manually enter the secret into your Authenticator app.
2. Read the current 6-digit TOTP code.
3. Type the 6 digits into the verification input.
4. Tap **"Doğrula ve Etkinleştir"**.
5. Observe success:
   - A green confirmation banner: *"İki faktörlü doğrulama başarıyla etkinleştirildi"*.
   - Status badge transitions to **"Etkin"** (Enabled) with a green checkmark.
   - The button now offers **"İki Faktörlü Doğrulamayı Devre Dışı Bırak"**.

### Step 4: Disable 2FA
1. Tap **"İki Faktörlü Doğrulamayı Devre Dışı Bırak"**.
2. A confirmation dialog appears asking for the current 6-digit TOTP code.
3. Enter the current code from the Authenticator app and confirm.
4. Observe:
   - Success message: *"İki faktörlü doğrulama devre dışı bırakıldı"*.
   - Status transitions back to **"Devre Dışı"**.
