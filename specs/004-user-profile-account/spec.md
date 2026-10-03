# Feature Specification: FEAT-04 — User Profile & Account Management

**Feature Branch**: `004-user-profile-account`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User description: "FEAT-04: User Profile & Account Management" (from docs/feature-breakdown.md and docs/spec.md)

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Kullanıcı Profil Bilgilerini Görüntüleme (Priority: P1)

Giriş yapmış (Authenticated) bir kullanıcı, profil/hesap ekranına girdiğinde kendi kimlik bilgilerini (`email`, `userId`, `role`) ve güncel iki faktörlü doğrulama (2FA) durumunu görüntüler.

**Why this priority**: Kullanıcının hangi hesapla giriş yaptığını, yetki rolünü (`User` veya `Admin`) ve hesap güvenlik seviyesini görmesi temel kullanıcı deneyimidir.

**Independent Test**: Ana ekrandan profil ikonuna dokunulduğunda `GET /api/Users/me` çağrılır; kullanıcının e-posta adresi, kullanıcı ID'si, rolü ve 2FA durumu kartlar halinde görüntülenir.

**Acceptance Scenarios**:

1. **Given** kullanıcı oturum açmış, **When** profil ekranını açtığında, **Then** `GET /api/Users/me` çağrılır ve kullanıcının e-posta adresi, ID'si ve rolü ekranda listelenir.
2. **Given** kullanıcı profil ekranında, **When** kullanıcı ID'sinin yanındaki kopyalama butonuna bastığında, **Then** ID panoya kopyalanır ve bildirim verilir.
3. **Given** profil verisi yüklenirken, **When** ağ hatası oluşursa, **Then** kullanıcıya hata bildirimi ve "Yeniden Dene" seçeneği sunulur.

---

### User Story 2 - Oturum Açıkken Şifre Değiştirme (Priority: P1)

Kullanıcı mevcut şifresini bilerek hesabının şifresini güncellemek istediğinde, "Şifre Değiştir" formunu açar; mevcut şifresini, yeni şifresini ve yeni şifre tekrarını girerek şifresini güvenle günceller.

**Why this priority**: Şifre yenileme periyodik hesap güvenliğinin en kritik parçasıdır; unutulan şifre (FEAT-02) haricinde kullanıcının kendi isteğiyle şifre güncellemesini sağlar.

**Independent Test**: Profil ekranından "Şifre Değiştir" seçildiğinde mevcut şifre ve yeni şifre girilip onaylanır; `PUT /api/Auth/change-password` çağrılır, 204 No Content yanıtı alındığında başarı mesajı gösterilir ve form temizlenir.

**Acceptance Scenarios**:

1. **Given** kullanıcı şifre değiştirme formunda, **When** doğru mevcut şifresini ve kurallara uygun (en az 8 karakter, büyük harf, rakam, özel karakter) yeni şifreyi girip kaydettiğinde, **Then** `PUT /api/Auth/change-password` çağrılır ve başarı bildirimi ("Şifreniz başarıyla değiştirildi") gösterilir.
2. **Given** kullanıcı mevcut şifresini hatalı girdiğinde, **When** formu gönderdiğinde, **Then** sunucudan dönen hata ("Mevcut şifre hatalı") kullanıcıya gösterilir ve işlem engellenir.
3. **Given** yeni şifre ve yeni şifre tekrarı birbiriyle eşleşmediğinde, **Then** buton pasif kalır veya istemci tarafında "Şifreler eşleşmiyor" uyarısı gösterilir.

---

### User Story 3 - Hesabı Kalıcı Olarak Silme (Priority: P2)

Kullanıcı hesabını ve tüm ilişkili verilerini sistemden kalıcı olarak silmek istediğinde, kazara silinmeleri önlemek amacıyla kırmızı uyarı diyaloguyla karşılaşır; hesap şifresini doğrulayarak silme işlemini onaylar.

**Why this priority**: KVKK / GDPR uyumluluğu ve kullanıcı veri sahipliği için zorunlu bir haktır; geri dönüşü olmayan bir işlem olduğundan parola doğrulamalı güvenlik bariyeri gerektirir.

**Independent Test**: "Hesabımı Sil" butonuna basıldığında açılan onay penceresinde hesap şifresi girilir; `DELETE /api/Users/me` çağrılır, 204 No Content yanıtı alındığında yerel token'lar temizlenir ve kullanıcı Login ekranına güvenle yönlendirilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı profil ekranında, **When** "Hesabımı Sil" butonuna bastığında, **Then** işlemin geri alınamaz olduğunu belirten kırmızı vurgulu bir onay penceresi açılır ve kullanıcıdan şifresi istenir.
2. **Given** kullanıcı doğru şifresini girip silmeyi onayladığında, **Then** `DELETE /api/Users/me` çağrılır; yerel güvenli depolamadaki tüm token'lar silinir (`clearAuthData`), `AuthBloc` çıkış durumuna geçirilir ve kullanıcı Login ekranına aktarılır.
3. **Given** kullanıcı yanlış şifre girdiğinde, **When** silmeyi onaylamaya çalıştığında, **Then** silme işlemi reddedilir, hata mesajı gösterilir ve hesap aktif kalmaya devam eder.

---

## Edge Cases

- **Ağ Kesintisi:** Şifre değiştirme veya hesap silme sırasında bağlantı koparsa hata mesajı gösterilir, oturum açık kalır ve kullanıcı tekrar deneyebilir.
- **Hesap Silindikten Sonra:** Cihazda saklanan JWT Access Token ve Refresh Token tamamen temizlenir. Uygulama kapatılıp açılsa bile kullanıcı doğrudan Login ekranında başlar.
- **Admin Rolü:** Kullanıcının rolü `Admin` ise arayüzde özel bir "Yönetici" rozeti görüntülenir (İleriki FEAT-08 etiket yönetimi için zemin hazırlar).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistem, yalnızca oturum açmış kullanıcıların profil ekranına erişmesine izin vermelidir.
- **FR-002**: Sistem, `GET /api/Users/me` endpoint'inden kullanıcının `userId`, `email`, `role` ve `isTwoFactorEnabled` bilgilerini getirmelidir.
- **FR-003**: Sistem, kullanıcının `userId` değerini tek tıkla panoya kopyalamasına olanak tanımalıdır.
- **FR-004**: Sistem, şifre değiştirme işlemi için `currentPassword` ve `newPassword` alanlarını almalı ve istemci tarafında şifre güçlülük kurallarını doğrulamalıdır.
- **FR-005**: Sistem, şifre değiştirme talebini `PUT /api/Auth/change-password` endpoint'ine göndermeli ve 204 No Content yanıtında başarı bildirimi vermelidir.
- **FR-006**: Sistem, hesap silme işlemi için kullanıcıdan açık şifre teyidi almalı ve talebi `DELETE /api/Users/me` endpoint'ine iletmelidir.
- **FR-007**: Sistem, hesap silme başarılı olduğunda yerel kimlik bilgilerini (`SecureStorageService`) anında temizlemeli ve kullanıcıyı Login ekranına yönlendirmelidir.

---

### Key Entities

- **UserProfile**: `userId` (UUID), `email` (string), `role` (string), `isTwoFactorEnabled` (bool).
- **ChangePasswordRequest**: `currentPassword` (string), `newPassword` (string).
- **DeleteAccountRequest**: `password` (string).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Profil bilgileri ekran açıldıktan sonra 1 saniyenin altında yüklenmelidir.
- **SC-002**: Şifre değiştirme ve hesap silme form kontrolleri (eşleşme, uzunluk) anlık (100 ms altında) tepki vermelidir.
- **SC-003**: Hesap silme sonrasında yerel token'ların temizlenme başarı oranı %100 olmalı, eski token ile istek atılma riski sıfır olmalıdır.
