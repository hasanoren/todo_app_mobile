# Quickstart Validation Guide: FEAT-02 — Password Recovery & Deep Linking

**Feature**: FEAT-02 (Password Recovery & Deep Linking)  
**Date**: 2026-10-03  
**Target API**: `https://todoapp-api-gudhgje6bvfqg3ev.centralus-01.azurewebsites.net`  

---

## 1. Prerequisites & Setup

### Environment
- Flutter 3.x+ installed and running on Android emulator / iOS simulator / physical device.
- Working internet connection to reach backend API.
- Android ADB command line tools available for simulating deep links.

---

## 2. End-to-End Validation Scenarios

### Scenario 1: Şifremi Unuttum Ekranına Erişim ve İstek Gönderimi
1. Uygulamayı başlatın (Giriş ekranı açılacaktır).
2. Giriş formunun altındaki **"Şifremi Unuttum"** butonuna dokunun.
3. `/forgot-password` rotasının açıldığını ve e-posta giriş alanının geldiğini doğrulayın.
4. Kayıtlı bir e-posta adresi girin (örn: `test@example.com`) ve **"Sıfırlama Bağlantısı Gönder"** butonuna dokunun.
5. **Beklenen Sonuç:**
   - `POST /api/Auth/forgot-password` çağrılır (`200 OK`).
   - "Eğer bu e-posta adresi kayıtlıysa, şifre sıfırlama bağlantısı gönderilmiştir." mesajı gösterilir.
   - Buton üzerinde 60 saniyelik görsel geri sayım sayacı başlar ("Tekrar göndermek için 60 sn bekleyin") ve buton kilitlenir.
   - 60 saniye dolduğunda buton "Tekrar Gönder" metniyle yeniden aktifleşir.

---

### Scenario 2: Özel Şema (`todoapp://`) ile Derin Bağlantı Açılışı (Emülatör Testi)
1. Terminalden Android emülatörüne şu ADB komutunu göndererek gelen linki simüle edin:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "todoapp://reset-password?token=TEST_TOKEN_123" com.example.todo_app_mobile
   ```
2. **Beklenen Sonuç:**
   - Uygulama otomatik olarak açılır veya ön plana gelir.
   - `GoRouter` gelen URL'i yakalar ve `/reset-password` ekranına yönlendirir.
   - Ekranda "Yeni Şifre" ve "Yeni Şifre Tekrarı" alanları görüntülenir.

---

### Scenario 3: Yeni Şifre Belirleme ve Girişe Dönüş
1. Şifre sıfırlama ekranında:
   - Yeni Şifre alanına: `NewPassword123!`
   - Yeni Şifre Tekrarı alanına: `NewPassword123!` girin.
2. **"Şifreyi Güncelle"** butonuna dokunun.
3. **Beklenen Sonuç:**
   - `POST /api/Auth/reset-password` isteği decode edilmiş token ile gönderilir.
   - Başarı mesajı ("Şifreniz başarıyla değiştirildi. Yeni şifrenizle giriş yapabilirsiniz.") görüntülenir.
   - Kullanıcı otomatik olarak `/login` ekranına yönlendirilir.
   - Giriş ekranındaki e-posta alanı otomatik doldurulmuş olarak gelir ve şifre kutusuna odaklanılır.

---

### Scenario 4: Bozuk veya Süresi Dolmuş Belirteç Senaryosu
1. Geçersiz bir belirteç ile bağlantıyı tetikleyin:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "todoapp://reset-password?token=INVALID_EXPIRED_TOKEN" com.example.todo_app_mobile
   ```
2. Yeni şifre alanlarını doldurup "Şifreyi Güncelle" butonuna dokunun.
3. **Beklenen Sonuç:**
   - Sunucudan `400 Bad Request` yanıtı döner.
   - Ekranda "Sıfırlama bağlantısının süresi dolmuş veya geçersiz. Lütfen yeni bir bağlantı talep edin." uyarısı ve **"Yeni Bağlantı İste"** butonu gösterilir.
   - Butona basıldığında kullanıcı `/forgot-password` ekranına geri aktarılır.
