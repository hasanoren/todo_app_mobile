# Research & Architectural Decisions: FEAT-02 (Password Recovery & Deep Linking)

**Feature**: FEAT-02 — Password Recovery & Deep Linking  
**Date**: 2026-10-03  
**Status**: Completed  

---

## 1. Deep Linking Architecture in Flutter & GoRouter

### Context
Kullanıcılar e-postalarına gelen sıfırlama linkine tıkladıklarında mobil uygulamanın otomatik olarak açılması ve gelen URL içerisindeki `token` parametresinin (URL-decode edilerek) yakalanıp "Şifre Sıfırla" ekranına aktarılması gerekmektedir. Şartname gereği hem özel şema (`todoapp://reset-password?token=...`) hem de evrensel web bağlantıları (`https://.../reset-password?token=...`) desteklenmelidir.

### Decision
- **Yönlendirme Çatısı:** Mevcut `GoRouter` yapılandırmasına iki yeni rota eklenecektir:
  - `/forgot-password`: Şifremi unuttum e-posta giriş ekranı
  - `/reset-password`: Gelen deep link ile açılan yeni şifre belirleme ekranı (`token` query parametresi ile)
- **Token Ayrıştırma (URL-Decoding):** `GoRouterState.uri.queryParameters['token']` değeri doğrudan okunur. `Uri` sınıfı Dart standardı gereği URL parametrelerini otomatik decode eder; ancak özel karakter kaçışlarını garantiye almak için `Uri.decodeComponent` kontrolü uygulanacaktır.
- **Platform Yapılandırması:**
  - **Android (`AndroidManifest.xml`):** `MainActivity` altına `android.intent.action.VIEW` içeren iki intent-filter eklenir:
    1. `<data android:scheme="todoapp" android:host="reset-password" />`
    2. `<data android:scheme="https" android:host="todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net" android:pathPrefix="/reset-password" />`
  - **iOS (`Info.plist`):** `CFBundleURLTypes` altına `CFBundleURLSchemes` olarak `todoapp` eklenir.

### Rationale
- `GoRouter`, derin bağlantıları yerel olarak dinleme ve rota parametrelerini `state.uri.queryParameters` üzerinden ayıklama yeteneğine sahiptir. Harici bir deep link paketine (uni_links vb.) ihtiyaç duymadan GoRouter ve platform manifest ayarlarıyla sıfır ek bağımlılıkla çalışır.

### Alternatives Considered
- *Harici paket (`app_links` / `uni_links`)*: GoRouter v14+ zaten `PlatformRouteInformationProvider` üzerinden gelen tüm deep link'leri yakalayabilmektedir. Harici paket eklemek gereksiz karmaşıklık ve bağımlılık riski yaratır (Anayasa VII - Simplicity & YAGNI).

---

## 2. Şifremi Unuttum Ekranında Geri Sayım Sayacı (Cooldown Timer)

### Context
Kullanıcı e-posta adresini girip "Sıfırlama Bağlantısı Gönder" dediğinde backend'deki `POST /api/Auth/forgot-password` uç noktası dakikada en fazla 2 isteğe izin vermektedir (`429 Too Many Requests`). Kullanıcının art arda butona basmasını engellemek için buton üzerinde 60 saniyelik bir görsel geri sayım sayacı çalıştırılmalıdır.

### Decision
- `ForgotPasswordCubit` içerisinde bir `Timer? _cooldownTimer` tutulacaktır.
- İstek başarılı (`200 OK`) döndüğünde:
  1. `cooldownSeconds = 60` olarak atanır ve state emit edilir.
  2. Her saniye `Timer.periodic` ile `cooldownSeconds` bir azaltılır.
  3. Süre `0` olduğunda sayaç durdurulur ve buton "Tekrar Gönder" metniyle yeniden aktif hale gelir.
- Cubit kapandığında (`close()`) timer bellek sızıntısını önlemek için iptal (`cancel()`) edilir.

### Rationale
- Hız sınırı hatasını reaktif olarak (429 geldikten sonra) göstermek yerine, istemci tarafında proaktif olarak 60 saniyelik sayaç koymak kullanıcı deneyimini (UX) üst seviyeye çıkarır ve gereksiz ağ trafiğini engeller.

---

## 3. Yeni Şifre Kuralları ve Çift Doğrulama (Password Confirmation)

### Context
Kullanıcının belirleyeceği yeni şifrenin güvenlik kurallarını (en az 8 karakter, 1 büyük harf, 1 rakam, 1 özel karakter) karşılaması ve "Yeni Şifre Tekrarı" alanı ile birebir uyuşması gerekmektedir.

### Decision
- `ResetPasswordCubit` iki alanı yönetir: `password` ve `confirmPassword`.
- Doğrulama mantığı:
  - Şifre kuralı: `RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-+=]).{8,}$')`
  - Eşleşme kontrolü: `password == confirmPassword`
- Hatalar anlık olarak ilgili `AuthTextField` üzerinde gösterilir.

---

## 4. Şifre Sıfırlama Sonrası Giriş Ekranına Veri Aktarımı (Pre-filled Email)

### Context
Kullanıcı şifresini başarıyla sıfırladıktan sonra Giriş (Login) ekranına yönlendirilmeli ve e-posta alanı otomatik doldurulmalıdır.

### Decision
- `GoRouter` navigasyonu ile Login rotasına parametre aktarılır:
  ```dart
  context.go(RouteNames.login, extra: {'email': email, 'message': 'Şifreniz başarıyla değiştirildi. Yeni şifrenizle giriş yapabilirsiniz.'});
  ```
- `LoginScreen`, `GoRouterState` üzerinden gelen `extra` parametresini kontrol eder; eğer `email` varsa `LoginCubit` state'ine otomatik aktarır ve ekranda başarı SnackBar'ı gösterir.

### Rationale
- Kullanıcı şifresini henüz değiştirmişken tekrar e-posta adresini elle yazmak zorunda kalmaz; doğrudan yeni şifresini yazıp tek dokunuşla sisteme giriş yapar.
