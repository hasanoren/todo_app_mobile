# Feature Specification: Authentication & Session Lifecycle

**Feature ID**: FEAT-01

**Feature Branch**: `001-auth-session`

**Created**: 2026-10-02

**Status**: Draft

**Input**: User description: "FEAT-01: Authentication & Session Lifecycle — Provide secure user registration, login (including 2FA challenge resolution), automatic token management, and logout."

## Clarifications

### Session 2026-10-02

- Q: Hesap kilitleme (account lockout) mekanizması var mı? → A: Hesap kilitleme yok; yalnızca hız sınırı (5 deneme/dakika) geçerlidir.
- Q: Oturum süresi dolduğunda kullanıcıya nasıl davranılmalı? → A: Bilgilendirmeli yönlendirme — "Oturumunuzun süresi doldu" mesajı gösterilir, ardından giriş ekranına yönlendirilir.
- Q: İstemci tarafında şifre doğrulama kuralları nelerdir? → A: Minimum 8 karakter + en az 1 büyük harf + 1 rakam + 1 özel karakter.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Yeni Kullanıcı Kaydı (Priority: P1)

Henüz hesabı olmayan bir kullanıcı, uygulamayı ilk kez açar ve bir hesap oluşturmak ister. E-posta adresi ve şifre girerek kayıt olur. Başarılı kayıt sonrasında otomatik olarak ana ekrana yönlendirilir ve oturumu açık kalır.

**Why this priority**: Kayıt, uygulamaya giriş noktasıdır. Kayıt yapılamadan diğer hiçbir özellik kullanılamaz.

**Independent Test**: Uygulamayı ilk kez açarak kayıt formunu doldurup hesap oluşturulabilir ve ana ekranın göründüğü doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı kayıt ekranında, **When** geçerli bir e-posta ve şifre girip "Kayıt Ol" düğmesine basar, **Then** hesap oluşturulur, oturum açılır ve kullanıcı ana ekrana yönlendirilir.
2. **Given** kullanıcı kayıt ekranında, **When** zaten kayıtlı bir e-posta adresi girer, **Then** uygun bir hata mesajı görüntülenir ve form yeniden düzenlenebilir durumda kalır.
3. **Given** kullanıcı kayıt ekranında, **When** geçersiz formatta e-posta veya kurallara uymayan şifre girer, **Then** alan bazlı doğrulama hataları anında gösterilir.
4. **Given** kullanıcı kayıt ekranında, **When** dakikada 3'ten fazla kayıt denemesi yapar, **Then** hız sınırı uyarısı görüntülenir ve kullanıcı beklemeye yönlendirilir.

---

### User Story 2 - Standart Giriş (Priority: P1)

Mevcut bir hesaba sahip kullanıcı, e-posta ve şifresiyle giriş yapar. 2FA aktif değilse doğrudan ana ekrana yönlendirilir.

**Why this priority**: Giriş, uygulamanın temel kapısıdır ve tüm korumalı özelliklere erişim sağlar.

**Independent Test**: Kayıtlı e-posta ve şifre ile giriş yapılarak ana ekranın göründüğü doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı giriş ekranında, **When** doğru e-posta ve şifre girip "Giriş" düğmesine basar (2FA kapalı), **Then** oturum açılır ve kullanıcı ana ekrana yönlendirilir.
2. **Given** kullanıcı giriş ekranında, **When** yanlış şifre girer, **Then** "Geçersiz kimlik bilgileri" hata mesajı görüntülenir.
3. **Given** kullanıcı giriş ekranında, **When** kayıtlı olmayan bir e-posta girer, **Then** güvenlik nedeniyle aynı genel hata mesajı görüntülenir (kullanıcı numaralandırma koruması).
4. **Given** kullanıcı giriş ekranında, **When** dakikada 5'ten fazla giriş denemesi yapar, **Then** hız sınırı uyarısı görüntülenir.

---

### User Story 3 - 2FA Giriş Doğrulaması (Priority: P2)

2FA etkinleştirilmiş bir kullanıcı giriş yapar. Sistem, e-posta ve şifre doğrulandıktan sonra 6 haneli TOTP kodu ister. Doğru kodu giren kullanıcı ana ekrana yönlendirilir.

**Why this priority**: 2FA etkin kullanıcıların giriş yapabilmesi için gerekli. Kayıt ve standart girişten sonra ikinci önemli giriş akışıdır.

**Independent Test**: 2FA etkin bir hesapla giriş yapıldığında kod ekranının göründüğü ve doğru kod ile oturumun açıldığı doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı giriş ekranında e-posta ve şifresini doğru girdi ve hesabında 2FA etkin, **When** giriş düğmesine basar, **Then** sistem 2FA doğrulama ekranına yönlendirir.
2. **Given** kullanıcı 2FA kod ekranında, **When** authenticator uygulamasından doğru 6 haneli kodu girer, **Then** oturum açılır ve ana ekrana yönlendirilir.
3. **Given** kullanıcı 2FA kod ekranında, **When** yanlış veya süresi geçmiş bir kod girer, **Then** hata mesajı gösterilir ve yeni kod girilebilir.
4. **Given** kullanıcı 2FA kod ekranında, **When** geri tuşuna basar, **Then** giriş ekranına döner ve yeni bir giriş denemesi yapabilir.

---

### User Story 4 - Otomatik Oturum Yenileme (Priority: P1)

Oturumu açık olan bir kullanıcı uygulamayı kullanmaya devam eder. Erişim belirteci (access token) süresinin dolmasına yakın, sistem arka planda otomatik olarak yeni bir belirteç alır. Kullanıcı bu süreçten etkilenmez ve kesintisiz çalışmaya devam eder.

**Why this priority**: Token yenileme olmadan kullanıcılar her 60 dakikada bir tekrar giriş yapmak zorunda kalır, bu kabul edilemez bir kullanıcı deneyimidir.

**Independent Test**: Oturum açıkken 60 dakika beklendiğinde (veya token süresi simüle edildiğinde) kullanıcının giriş ekranına düşmediği doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcının erişim belirtecinin süresi dolmak üzere, **When** kullanıcı bir istek gönderir, **Then** sistem arka planda yeni bir belirteç alır ve istek kesintisiz tamamlanır.
2. **Given** yenileme belirteci (refresh token) geçersiz veya süresi dolmuş, **When** sistem yenileme dener, **Then** kullanıcıya "Oturumunuzun süresi doldu, lütfen tekrar giriş yapın" mesajı gösterilir ve giriş ekranına yönlendirilir.
3. **Given** eşzamanlı birden fazla istek token yenileme gerektiriyor, **When** aynı anda birden fazla istek başarısız olur, **Then** yalnızca bir yenileme işlemi gerçekleştirilir ve bekleyen tüm istekler yeni belirteçle yeniden denenir.

---

### User Story 5 - Çıkış Yapma (Priority: P2)

Kullanıcı oturumunu sonlandırmak ister. Çıkış yaptığında sunucudaki yenileme belirteci iptal edilir, cihazdaki tüm kimlik bilgileri temizlenir ve giriş ekranına yönlendirilir.

**Why this priority**: Güvenli oturum sonlandırma, özellikle paylaşılan cihazlarda kritiktir.

**Independent Test**: Çıkış yaptıktan sonra giriş ekranının göründüğü ve eski belirteçlerle işlem yapılamadığı doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı oturumu açık, **When** "Çıkış Yap" düğmesine basar, **Then** sunucudaki yenileme belirteci iptal edilir, cihazdaki tüm belirteçler silinir ve giriş ekranı görüntülenir.
2. **Given** kullanıcı çıkış yapmış, **When** uygulamayı yeniden açar, **Then** giriş ekranı görüntülenir (otomatik giriş yapılmaz).
3. **Given** ağ bağlantısı kesilmiş, **When** kullanıcı çıkış yapmak ister, **Then** yerel kimlik bilgileri yine temizlenir ve giriş ekranına yönlendirilir (sunucu tarafı iptal ağ geldiğinde yapılabilir).

---

### User Story 6 - Uygulama Yeniden Açılışında Oturum Devamı (Priority: P2)

Kullanıcı uygulamayı kapatıp yeniden açar. Daha önce giriş yapmışsa ve belirteçleri hâlâ geçerliyse, giriş ekranı atlanarak doğrudan ana ekrana yönlendirilir.

**Why this priority**: Her açılışta tekrar giriş yapmak kullanıcı deneyimini ciddi şekilde bozar.

**Independent Test**: Giriş yapıp uygulamayı kapatıp tekrar açtığında doğrudan ana ekranın göründüğü doğrulanabilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı daha önce giriş yapmış ve belirteçleri geçerli, **When** uygulamayı yeniden açar, **Then** giriş ekranı atlanır ve ana ekran gösterilir.
2. **Given** kullanıcı daha önce giriş yapmış ancak belirteçlerin süresi dolmuş, **When** uygulamayı yeniden açar, **Then** arka planda yenileme denenir; başarılıysa ana ekran, başarısızsa giriş ekranı gösterilir.

---

### Edge Cases

- Kullanıcı kayıt sırasında ağ bağlantısını kaybederse ne olur? → İstek zaman aşımına uğrar ve anlamlı bir hata mesajı gösterilir.
- Aynı anda birden fazla sekmede/cihazda giriş yapılırsa ne olur? → Her cihaz kendi belirteç çiftini alır; birinin çıkışı diğerini etkilemez (yalnızca o cihazın refresh token'ı iptal edilir).
- Kullanıcı 2FA kod ekranında uzun süre beklerse ne olur? → Geçici 2FA belirtecinin süresi dolarsa, kullanıcı yeniden e-posta/şifre ile giriş yapmalıdır.
- Sunucu beklenmedik bir hata (500) döndürürse ne olur? → Genel bir hata mesajı gösterilir ve kullanıcı tekrar denemeye yönlendirilir.
- Kullanıcı uygulamayı ilk kez açtığında hangi ekranı görür? → Daha önce giriş yapılmamışsa giriş ekranı (kayıt seçeneğiyle birlikte) gösterilir.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistem, geçerli e-posta ve şifre ile yeni kullanıcı kaydı oluşturabilmelidir.
- **FR-002**: Sistem, kayıt sonrasında otomatik olarak erişim belirteci ve yenileme belirteci döndürmelidir.
- **FR-003**: Sistem, e-posta ve şifre ile kullanıcı girişi yapabilmelidir.
- **FR-004**: Sistem, giriş yanıtında 2FA gereksinimi tespit edip uygun akışa yönlendirmelidir (2FA gerektiğinde ana belirteçler null döner, geçici 2FA belirteci sağlanır).
- **FR-005**: Sistem, geçici 2FA belirteci ve 6 haneli TOTP kodu ile 2FA giriş doğrulamasını tamamlayabilmelidir.
- **FR-006**: Sistem, yenileme belirteci kullanarak mevcut oturumu uzatabilmeli ve yeni bir belirteç çifti alabilmelidir. Yenileme sırasında eski yenileme belirteci anında geçersiz kılınır.
- **FR-007**: Sistem, erişim belirtecinin süresinin dolmasından önce proaktif olarak arka planda yenileme yapmalıdır. Erişim belirteci süresi 60 dakikadır.
- **FR-008**: Sistem, eşzamanlı token yenileme isteklerini tek bir yenileme işlemiyle koordine etmelidir (mutex/queue mekanizması).
- **FR-009**: Sistem, çıkış işleminde sunucudaki yenileme belirtecini iptal etmeli ve cihazdaki tüm kimlik bilgilerini güvenli şekilde silmelidir.
- **FR-010**: Sistem, erişim belirtecini ve yenileme belirtecini cihazın güvenli depolama alanında saklamalıdır (düz metin dosyaları veya standart tercihler kullanılmamalıdır).
- **FR-011**: Sistem, uygulama yeniden açıldığında mevcut belirteçleri kontrol etmeli ve geçerliyse giriş ekranını atlamalıdır.
- **FR-012**: Sistem, kayıt ve giriş ekranlarında alan bazlı doğrulama hataları göstermelidir (sunucu doğrulama yanıtları RFC 7807 formatında döner).
- **FR-013**: Sistem, hız sınırı aşıldığında (kayıt: 3/dk, giriş: 5/dk) kullanıcıya bilgilendirici bir mesaj göstermelidir.
- **FR-014**: Sistem, korumalı isteklerde erişim belirtecini otomatik olarak istek başlığına eklemelidir.
- **FR-015**: Sistem, ağ hataları ve sunucu hataları (500) durumunda kullanıcıya anlamlı hata mesajları göstermelidir.
- **FR-016**: Sistem, şifre alanında istemci tarafı doğrulama olarak minimum 8 karakter, en az 1 büyük harf, en az 1 rakam ve en az 1 özel karakter kurallarını uygulamalıdır.
- **FR-017**: Sistem, oturum süresi dolduğunda (refresh token geçersiz) kullanıcıya "Oturumunuzun süresi doldu, lütfen tekrar giriş yapın" mesajı göstermeli ve giriş ekranına yönlendirmelidir.
- **FR-018**: Sistem, başarısız giriş denemelerinde hesap kilitleme uygulamaMALIDIR; güvenlik yalnızca sunucu tarafındaki hız sınırı (5 deneme/dakika) ile sağlanır.

### Key Entities

- **Kullanıcı (User)**: Benzersiz tanımlayıcı (userId), e-posta adresi ve kimlik doğrulama durumunu temsil eder.
- **Erişim Belirteci (Access Token)**: Korumalı kaynaklara erişim için kullanılan, 60 dakika geçerliliği olan JWT formatında belirteç.
- **Yenileme Belirteci (Refresh Token)**: Yeni erişim belirteci almak için kullanılan tek kullanımlık belirteç. Her yenileme sonrasında eski belirteç geçersiz olur.
- **2FA Geçici Belirteci (Two-Factor Token)**: 2FA gereken giriş akışında, e-posta/şifre doğrulandıktan sonra döndürülen ve TOTP kodu ile birlikte kullanılan geçici belirteç.
- **Oturum Durumu (Session State)**: Uygulamanın genel kimlik doğrulama durumu — kimlik doğrulanmamış, 2FA bekleniyor veya kimlik doğrulanmış.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Kullanıcılar kayıt işlemini 30 saniyeden kısa sürede tamamlayabilmelidir.
- **SC-002**: Kullanıcılar standart giriş işlemini (2FA hariç) 15 saniyeden kısa sürede tamamlayabilmelidir.
- **SC-003**: 2FA doğrulama akışı dahil giriş süreci 45 saniyeden kısa sürede tamamlanabilmelidir.
- **SC-004**: Erişim belirteci yenileme süreci kullanıcı tarafından fark edilmemelidir (kesintisiz deneyim).
- **SC-005**: Çıkış sonrası tüm yerel kimlik bilgileri 1 saniye içinde temizlenmelidir.
- **SC-006**: Uygulama yeniden açılışında oturum kontrolü 2 saniyeden kısa sürede tamamlanmalı ve uygun ekrana yönlendirmelidir.
- **SC-007**: Tüm doğrulama hataları kullanıcıya alan bazında anlaşılır Türkçe mesajlarla gösterilmelidir.
- **SC-008**: Hız sınırı aşıldığında kullanıcı beklemeye yönlendirilmeli ve ne kadar beklemesi gerektiği konusunda bilgilendirilmelidir.

## Assumptions

- Kullanıcıların kayıt ve giriş sırasında aktif internet bağlantısı vardır (çevrimdışı kayıt/giriş desteklenmez).
- Backend API çalışır durumda ve `docs/spec.md`'de belgelenen yanıt formatlarına uyar.
- Şifre kuralları: İstemci tarafında minimum 8 karakter + en az 1 büyük harf + 1 rakam + 1 özel karakter doğrulanır. Backend ek kurallar döndürürse RFC 7807 hata mesajları olarak gösterilir.
- E-posta doğrulaması standart RFC 5322 formatına uyar (tam kurallar API spesifikasyonunda belirsiz — Q2).
- Hız sınırı yanıtlarının RFC 7807 formatına uyup uymadığı ve `Retry-After` başlığı içerip içermediği belirsizdir (Q8); istemci genel bir bekleme mesajı gösterecektir.
- 2FA için kullanıcının harici bir authenticator uygulaması (Google Authenticator, Microsoft Authenticator vb.) zaten kurulu olduğu varsayılır. 2FA etkinleştirme/devre dışı bırakma bu feature'ın kapsamı dışındadır (FEAT-03).
- Parola sıfırlama ve derin bağlantı akışı bu feature'ın kapsamı dışındadır (FEAT-02).
