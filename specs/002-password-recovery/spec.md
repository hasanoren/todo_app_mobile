# Feature Specification: FEAT-02 — Password Recovery & Deep Linking

**Feature Branch**: `002-password-recovery`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User description: "FEAT-02: Password Recovery & Deep Linking" (from docs/feature-breakdown.md and docs/spec.md)

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Şifremi Unuttum Bağlantısı İsteme (Priority: P1)

Kayıtlı bir kullanıcı şifresini unuttuğunda, giriş ekranındaki "Şifremi Unuttum" seçeneğine tıklayarak e-posta adresini girer ve şifre sıfırlama bağlantısı talep eder.

**Why this priority**: Kullanıcının hesabına yeniden erişim sağlayabilmesi için başlangıç adımıdır; bu adım olmadan kurtarma süreci başlayamaz.

**Independent Test**: Giriş ekranından "Şifremi Unuttum" ekranına gidilip geçerli formatta bir e-posta adresi yazılarak talep gönderildiğinde, e-posta sistemde kayıtlı olsun ya da olmasın başarılı bilgilendirme mesajının gösterildiği doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı giriş ekranında, **When** "Şifremi Unuttum" bağlantısına tıkladığında, **Then** e-posta giriş alanının ve "Sıfırlama Bağlantısı Gönder" butonunun bulunduğu şifre kurtarma ekranına yönlendirilir.
2. **Given** kullanıcı şifremi unuttum ekranında, **When** geçerli formatta bir e-posta adresi girip gönderdiğinde, **Then** sistem "Eğer bu e-posta adresi kayıtlıysa, şifre sıfırlama bağlantısı gönderilmiştir." mesajını gösterir ve kullanıcıyı bilgilendirir.
3. **Given** kullanıcı şifremi unuttum ekranında, **When** geçersiz veya boş bir e-posta adresi girdiğinde, **Then** buton pasif kalır veya istemci tarafında "Geçerli bir e-posta adresi giriniz" uyarı mesajı gösterilir.
4. **Given** kullanıcı kısa süre içinde mükerrer talep gönderdiğinde (dakikada 2'den fazla), **Then** sistem hız sınırı aşıldığına dair kullanıcı dostu bir bekleme uyarısı gösterir.

---

### User Story 2 - Derin Bağlantı (Deep Link) ile Şifre Sıfırlama Ekranına Ulaşma (Priority: P1)

Kullanıcı e-postasına gelen bağlantıya mobil cihazından tıkladığında, uygulama otomatik olarak açılır, URL içindeki güvenlik belirteci (reset token) çözümlenir ve kullanıcı doğrudan "Yeni Şifre Belirleme" ekranına yönlendirilir.

**Why this priority**: Mobil kullanıcı deneyiminin kesintisiz olması ve kullanıcının belirteci elle kopyalamak zorunda kalmaması için kritik bağlantı köprüsüdür.

**Independent Test**: Cihaz tarayıcısından veya test komutundan sıfırlama bağlantısı tetiklendiğinde uygulamanın açılarak token parametresini tanıdığı ve şifre belirleme ekranını sunduğu doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** mobil cihazda gelen şifre sıfırlama bağlantısına tıklandığında, **When** uygulama açılır veya ön plana gelir, **Then** URL'deki belirteç otomatik olarak okunur, URL kodlaması çözülür (URL-decode) ve kullanıcı yeni şifre belirleme ekranına aktarılır.
2. **Given** gelen bağlantı bozuk, eksik veya belirteç parametresi içermiyor, **When** uygulama açıldığında, **Then** kullanıcıya geçersiz bağlantı uyarısı gösterilir ve ana giriş ekranına yönlendirilir.

---

### User Story 3 - Yeni Şifre Belirleme ve Girişe Yönlendirme (Priority: P1)

Geçerli bir belirteçle şifre sıfırlama ekranına ulaşan kullanıcı, güvenlik kurallarına uygun yeni bir şifre belirler ve onaylar. Şifre başarıyla güncellendikten sonra kullanıcı giriş ekranına yönlendirilir.

**Why this priority**: Şifre kurtarma sürecinin nihai hedefidir; kullanıcının yeni kimlik bilgisiyle sisteme giriş yapabilmesini sağlar.

**Independent Test**: Şifre sıfırlama ekranında kurallara uygun yeni şifre ve şifre tekrarı girilip onaylandığında, şifrenin güncellendiği teyit edilip giriş ekranına başarılı bir mesajla yönlendirildiği doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı yeni şifre belirleme ekranında, **When** kurallara uygun şifre ve aynı şifre tekrarını girip onayladığında, **Then** şifre başarıyla güncellenir, "Şifreniz başarıyla değiştirildi. Yeni şifrenizle giriş yapabilirsiniz." mesajı gösterilir ve kullanıcı giriş ekranına aktarılır.
2. **Given** kullanıcı yeni şifre belirleme ekranında, **When** şifre kurallarına uymayan (8 karakterden kısa, büyük harf/rakam/özel karakter eksik) bir değer girdiğinde, **Then** ilgili kural eksikliği alan bazında anlık olarak gösterilir ve işlem engellenir.
3. **Given** kullanıcı yeni şifre belirleme ekranında, **When** şifre ve şifre tekrarı alanları birbiriyle eşleşmediğinde, **Then** "Şifreler eşleşmiyor" uyarısı gösterilir.

---

### User Story 4 - Süresi Dolmuş veya Geçersiz Belirteç Yönetimi (Priority: P2)

Kullanıcı süresi dolmuş veya daha önce kullanılmış bir bağlantıya tıkladığında ya da sunucu doğrulamasında belirteç geçersiz bulunduğunda, kullanıcı anlaşılır bir hata ile karşılanır ve yeni bir bağlantı talep etmeye yönlendirilir.

**Why this priority**: Hatalı durumlarda kullanıcının ekranda takılıp kalmasını önler ve net bir kurtarma yolu sunar.

**Independent Test**: Süresi geçmiş bir belirteç ile şifre sıfırlama denendiğinde sunucunun hatasının kullanıcıya açıklanıp "Yeni bağlantı iste" aksiyonunun sunulduğu doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcının belirteci geçersiz veya süresi dolmuş, **When** yeni şifresini göndermeye çalıştığında, **Then** sistem "Sıfırlama bağlantısının süresi dolmuş veya geçersiz. Lütfen yeni bir bağlantı talep edin." uyarısı gösterir ve "Yeniden Bağlantı İste" butonu sunar.

---

### Edge Cases

- **Uygulama kapalıyken derin bağlantı açılırsa ne olur?** Uygulama sıfırdan başlarken derin bağlantıyı yakalar, başlangıç oturum kontrolünü beklemeden doğrudan şifre sıfırlama ekranını açar.
- **Uygulama zaten açıkken (arka planda) derin bağlantı açılırsa ne olur?** Mevcut ekran yığını üzerine şifre sıfırlama ekranı getirilir.
- **Kullanıcı şifre sıfırlama ekranındayken internet bağlantısı koparsa ne olur?** Şifre gönderme denemesinde ağ hatası uyarısı verilir, formdaki şifre alanları korunur, kullanıcının tekrar denemesine izin verilir.
- **Belirteç içinde özel karakterler varsa ne olur?** E-posta istemcileri tarafından URL-encode edilmiş karakterler (`%2B`, `%2F` vb.) istemci tarafında çözümlenerek ham belirteç sunucuya iletilir.
- **Kullanıcı şifresini sıfırladıktan sonra geri tuşuna basarsa ne olur?** Kullanıcı tekrar şifre sıfırlama ekranına dönemez, giriş ekranında kalır.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistem, giriş ekranında kullanıcıya "Şifremi Unuttum" ekranına giden açık bir erişim noktası sunmalıdır.
- **FR-002**: Sistem, şifre sıfırlama talebi için kullanıcının e-posta adresini almalı ve e-posta formatını doğrulamalıdır.
- **FR-003**: Sistem, e-posta adresi kayıtlı olsun veya olmasın kullanıcıya aynı jenerik başarı mesajını göstererek kullanıcı varlığı tespiti (user enumeration) yapılmasını engellemelidir.
- **FR-004**: Sistem, şifremi unuttum isteklerinde sunucu tarafı hız sınırına (dakikada 2 istek) uyulmadığı durumlarda kullanıcıya bilgilendirici bekleme mesajı göstermelidir.
- **FR-005**: Sistem, mobil işletim sisteminden gelen şifre sıfırlama derin bağlantılarını (deep links) dinlemeli ve yakalamalıdır.
- **FR-006**: Sistem, derin bağlantı içerisindeki sıfırlama belirteci (`token`) parametresini ayrıştırmalı ve URL kodlamasını (URL-decode) doğru şekilde çözmelidir.
- **FR-007**: Sistem, belirteç parametresi eksik veya geçersiz formatta olan derin bağlantılarda kullanıcıyı bilgilendirerek güvenli bir şekilde giriş ekranına yönlendirmelidir.
- **FR-008**: Sistem, yeni şifre ekranında "Yeni Şifre" ve "Yeni Şifre Tekrarı" alanlarını sunmalı ve şifrelerin birebir eşleştiğini doğrulamalıdır.
- **FR-009**: Sistem, yeni şifrenin asgari güvenlik kriterlerine (en az 8 karakter, en az 1 büyük harf, en az 1 rakam ve en az 1 özel karakter) uyduğunu istemci tarafında doğrulamalıdır.
- **FR-010**: Sistem, çözümlenen belirteç ve yeni şifre ile şifre sıfırlama isteğini sunucuya göndermelidir.
- **FR-011**: Sistem, şifre sıfırlama başarılı olduğunda kullanıcıya açık bir başarı mesajı gösterip giriş ekranına yönlendirmelidir.
- **FR-012**: Sistem, belirtecin geçersiz veya süresi dolmuş olması durumunda kullanıcıya anlamlı bir hata mesajı ile birlikte "Yeni Bağlantı İste" seçeneği sunmalıdır.

---

### Key Entities *(data involved)*

- **Şifre Sıfırlama Talebi (Password Reset Request)**: Kullanıcının kurtarma e-postası alması için gereken e-posta bilgisi.
- **Şifre Sıfırlama Belirteci (Reset Token)**: E-postadaki derin bağlantı ile gelen, sıfırlama oturumunu ve kullanıcının kimliğini doğrulayan tek kullanımlık güvenlik belirteci.
- **Yeni Şifre Bilgisi (New Password Payload)**: Kullanıcının belirlediği yeni şifre ve doğrulama belirtecinin birleşimi.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Kullanıcılar şifre sıfırlama bağlantısı talebini 20 saniyeden kısa sürede tamamlayabilmelidir.
- **SC-002**: Şifre sıfırlama bağlantısına tıklandığında uygulamanın açılıp şifre sıfırlama formunu göstermesi 2 saniyenin altında gerçekleşmelidir.
- **SC-003**: Şifre sıfırlama formu gönderildikten sonra başarılı yanıtın ekranda belirmesi 1 saniyenin altında olmalıdır.
- **SC-004**: Geçersiz formatlı e-posta veya zayıf şifre hataları kullanıcıya anlık (100 ms altında) geri bildirimle gösterilmelidir.
- **SC-005**: Belirteç çözümleme ve iletme sürecinde karakter bozulması kaynaklı hata oranı %0 olmalıdır.
- **SC-006**: Kullanıcıların en az %95'i şifre sıfırlama akışını ilk denemede yardım almadan tamamlayabilmelidir.

---

## Assumptions

- E-posta gönderim altyapısı ve e-posta şablonunun oluşturulması backend sorumluluğundadır.
- Derin bağlantı URL şeması olarak hem özel şema (`todoapp://reset-password?token=...`) hem de standart evrensel bağlantı (`https://.../reset-password?token=...`) mekanizmaları desteklenecektir.
- Sıfırlama belirtecinin geçerlilik süresi backend tarafından yönetilir (varsayılan: bağlantı oluşturulduktan sonra belirli bir süre içinde kullanılmalıdır).
- Kullanıcı şifresini sıfırladıktan sonra doğrudan otomatik oturum açılmaz; güvenlik gereği yeni şifresiyle giriş yapması istenir.
- Cihazda internet bağlantısı olmadığı durumlarda kullanıcıya standart ağ bağlantı hatası gösterilir.
