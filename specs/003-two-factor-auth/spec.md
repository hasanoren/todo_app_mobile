# Feature Specification: FEAT-03 — Two-Factor Authentication Management

**Feature Branch**: `003-two-factor-auth`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User description: "FEAT-03: Two-Factor Authentication Management" (from docs/feature-breakdown.md and docs/spec.md)

---

## Clarifications

### Session 2026-10-03
- Q: Kullanıcı İki Faktörlü Doğrulama (2FA) yönetim ekranına nereden erişsin? → A: Ana ekran (Home) üst barına Güvenlik/Ayarlar ikonu eklenerek doğrudan Güvenlik ekranına yönlendirilsin.
- Q: 2FA'yı devre dışı bırakırken kullanıcıdan hangi onay bilgisi istensin? → A: Sadece Authenticator uygulamasındaki 6 haneli güncel TOTP kodu doğrulansın (API standardı: `POST /api/Auth/2fa/disable`).

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 2FA Kurulumunu Başlatma ve QR Kod Görüntüleme (Priority: P1)

Giriş yapmış (Authenticated) bir kullanıcı, güvenlik/hesap ayarlarından İki Faktörlü Doğrulamayı (2FA) etkinleştirmek istediğinde, sistem kullanıcıya özel TOTP gizli anahtarını üretir ve ekranda taranabilir bir QR kod ile birlikte manuel giriş anahtarını sunar.

**Why this priority**: 2FA kurulumunun ilk adımıdır; kullanıcı authenticator uygulamasına (Google Authenticator, Microsoft Authenticator vb.) hesabı ekleyemezse doğrulama yapılamaz.

**Independent Test**: Güvenlik ayarlarından "2FA Etkinleştir" seçildiğinde, `POST /api/Auth/2fa/enable` çağrılır; gelen `qrCodeUri` kullanılarak QR kod çizilir ve `secret` metni kopyalama butonuyla birlikte ekranda gösterilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı oturum açmış ve ana ekranda/ayarlarda, **When** "İki Faktörlü Doğrulama" ayarına dokunduğunda, **Then** mevcut durum "Devre Dışı" olarak gösterilir ve "2FA Etkinleştir" butonu sunulur.
2. **Given** kullanıcı 2FA etkinleştirme akışını başlattığında, **When** sunucudan `secret` ve `qrCodeUri` başarıyla alındığında, **Then** ekranda net bir QR kod, manuel kurulum için gizli anahtar (secret key) ve "Panoya Kopyala" butonu gösterilir.
3. **Given** kullanıcı QR kodu authenticator ile tarayamıyorsa, **When** "Anahtarı Kopyala" butonuna bastığında, **Then** gizli anahtar panoya kopyalanır ve görsel bildirim ("Anahtar kopyalandı") verilir.

---

### User Story 2 - TOTP Kodu ile 2FA Etkinleştirmesini Doğrulama ve Tamamlama (Priority: P1)

Kullanıcı authenticator uygulamasına hesabı ekledikten sonra, oluşturulan 6 haneli dinamik kodu mobil uygulamaya girerek kurulumu doğrular ve 2FA'yı aktif hale getirir.

**Why this priority**: İki adımlı kurulum el sıkışmasının (handshake) tamamlanmasıdır; doğrulanmayan 2FA aktifleşmez, böylece kullanıcının hesabına kilitlenmesi engellenir.

**Independent Test**: Kurulum ekranında 6 haneli geçerli kod girilip "Doğrula ve Etkinleştir" butonuna basıldığında `POST /api/Auth/2fa/verify` çağrılır, 200 OK yanıtı alındığında başarı mesajı verilir ve durum "Etkin" olarak güncellenir.

**Acceptance Scenarios**:

1. **Given** kullanıcı QR kod ekranında, **When** authenticator uygulamasından aldığı 6 haneli kodu girip onayladığında, **Then** `POST /api/Auth/2fa/verify` çağrılır, başarı durumunda "İki faktörlü doğrulama başarıyla etkinleştirildi" mesajı gösterilir ve kullanıcı güvenlik ayarlarına yönlendirilir.
2. **Given** kullanıcı yanlış veya süresi dolmuş bir kod girdiğinde, **When** doğrula butonuna bastığında, **Then** kullanıcıya "Geçersiz doğrulama kodu. Lütfen tekrar deneyin." hatası gösterilir ve yeni kod girmesine izin verilir.
3. **Given** kullanıcı 6 haneden eksik kod girdiğinde, **When** formu incelediğinde, **Then** buton pasif kalır veya "Kod 6 haneli olmalıdır" uyarısı gösterilir.

---

### User Story 3 - İki Faktörlü Doğrulamayı Devre Dışı Bırakma (Priority: P2)

2FA'sı aktif olan bir kullanıcı, güvenliği düşürmek istediğinde yetkisiz kapatmaları önlemek amacıyla güncel 6 haneli TOTP kodunu girerek 2FA'yı güvenli bir şekilde kapatabilir.

**Why this priority**: Kullanıcı hesabında güvenlik tercihini değiştirebilmelidir; ancak telefonun başkasının eline geçmesi ihtimaline karşı kod doğrulaması şarttır.

**Independent Test**: 2FA aktifken "2FA'yı Devre Dışı Bırak" seçildiğinde açılan modal/diyalogda 6 haneli TOTP kodu istenir; kod doğrulanıp `POST /api/Auth/2fa/disable` çağrıldığında 2FA kapatılır ve durum "Devre Dışı" olur.

**Acceptance Scenarios**:

1. **Given** kullanıcının 2FA'sı etkin, **When** "2FA'yı Devre Dışı Bırak" seçeneğine bastığında, **Then** sistem güvenlik amacıyla güncel 6 haneli TOTP kodunu soran bir onay penceresi açar.
2. **Given** kullanıcı doğru 6 haneli kodu girdiğinde, **When** onayla butonuna bastığında, **Then** `POST /api/Auth/2fa/disable` çağrılır, başarılı mesajı gösterilir ve 2FA durumu "Devre Dışı"na döner.
3. **Given** kullanıcı hatalı kod girdiğinde, **When** onaylamaya çalıştığında, **Then** işlem reddedilir, hata mesajı gösterilir ve 2FA etkin kalmaya devam eder.

---

## Edge Cases

- **Ağ Kesintisi:** Kurulum sırasında QR kod alınırken veya kod doğrulanırken ağ kesilirse kullanıcıya yeniden deneme seçeneği sunulur; işlem yarım kalırsa 2FA sunucuda aktifleşmez.
- **Kullanıcı Kurulumu Tamamlamadan Geri Çıkarsa:** `/2fa/enable` çağrılmış ama `/2fa/verify` çağrılmamışsa, hesap güvenliği riske atılmamak için 2FA devre dışı kalmaya devam eder. Tekrar girildiğinde yeni bir secret üretilir.
- **Authenticator Saati Senkronizasyon Kayması:** Kullanıcı cihazı ile sunucu saati arasında hafif sapma varsa TOTP algoritması toleransı sunucu tarafında yönetilir; istemci tarafında başarısız olursa kullanıcının saat senkronizasyonunu kontrol etmesi önerilir.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistem, yalnızca oturum açmış (Authenticated) kullanıcıların 2FA yönetim ekranına erişmesine izin vermelidir.
- **FR-002**: Sistem, `POST /api/Auth/2fa/enable` çağrısı yaparak sunucudan `secret` ve `qrCodeUri` almalıdır.
- **FR-003**: Sistem, gelen `qrCodeUri` (`otpauth://...`) dizesini görsel bir QR kod olarak `qr_flutter` bileşeniyle ekranda çizmelidir.
- **FR-004**: Sistem, QR kodun altında manuel giriş için `secret` metnini açıkça göstermeli ve tek tıkla panoya kopyalama imkanı sağlamalıdır.
- **FR-005**: Sistem, 2FA aktivasyonu için kullanıcıdan 6 haneli sayısal TOTP kodunu almalı ve formatını doğrulamalıdır.
- **FR-006**: Sistem, girilen kod ile `POST /api/Auth/2fa/verify` isteği atarak aktivasyonu tamamlamalıdır.
- **FR-007**: Sistem, 2FA devre dışı bırakma talebinde `POST /api/Auth/2fa/disable` isteği ile birlikte 6 haneli güncel TOTP kodunu sunucuya göndermelidir.
- **FR-008**: Sistem, 2FA durumunu (Etkin / Devre Dışı) kullanıcı arayüzünde açık ve anlaşılır rozetlerle (badge) belirtmelidir.

---

### Key Entities

- **TwoFactorEnableResponse**: Sunucudan dönen `secret` (Base32 metin) ve `qrCodeUri` (`otpauth://totp/...`) verilerini içeren model.
- **TwoFactorVerifyRequest**: 6 haneli `code` içeren model.
- **TwoFactorDisableRequest**: 6 haneli `code` içeren model.
- **TwoFactorStatus**: Kullanıcının 2FA durumunu (`enabled`, `disabled`, `enabling`) temsil eden arayüz durumu.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 2FA kurulum ekranı ("Etkinleştir"e basıldıktan sonra) QR kod ve secret ile birlikte 1.5 saniyenin altında ekrana gelmelidir.
- **SC-002**: 6 haneli kod girildikten sonra doğrulama sonucu kullanıcıya 1 saniyenin altında gösterilmelidir.
- **SC-003**: Kurulum akışında gizli anahtarı kopyalama butonu tek dokunuşla panoya hatasız aktarılmalıdır (%100 doğruluk).
- **SC-004**: Doğrulama adımı tamamlanmadan hiçbir kullanıcının 2FA durumu sunucuda veya yerelde aktif olarak işaretlenmemelidir (Sıfır kilitlenme riski).
