# Geliştirme Süreci Özeti: FEAT-01 (Auth & Session Lifecycle)

Bu doküman, **Kimlik Doğrulama ve Oturum Yönetimi (Auth & Session)** özelliğinin geliştirilmesi sırasında uyguladığımız **Spec-Driven Development (Spesifikasyon Odaklı Geliştirme)** iş akışını ve her aşamada nelerin yapıldığını genel bir bakış açısıyla açıklamak amacıyla hazırlanmıştır. 

Dokümanın amacı kod detaylarından ziyade, bu spesifik özelliğin hangi mantıksal aşamalardan geçerek inşa edildiğini belgelemektir.

---

## 1. Constitution (Anayasa) Aşaması
**Soru:** *Projenin temel kuralları ve mimari sınırları nelerdir?*

Geliştirmeye başlamadan önce Auth özelliğinin uyması gereken katı teknik kuralları belirlediğimiz aşamadır.
- **Ne yapıldı?** Projenin mimarisi (Clean Architecture), durum yönetimi (Flutter Bloc), ağ katmanı (Dio) ve yönlendirme yapısı (GoRouter) gibi değişmez kararlar `.specify/memory/constitution.md` dosyasına kaydedildi.
- **Mantığı:** Geliştirilecek Auth modülündeki hiçbir kodun bu genel anayasa kurallarının (örneğin Bloc yerine Provider kullanmak gibi) dışına çıkmamasını garanti altına almak.

## 2. Specify (Spesifikasyon) Aşaması
**Soru:** *Auth özelliği tam olarak ne işe yarayacak, gereksinimler neler?*

Auth modülünün davranışsal sınırlarının çizildiği aşamadır.
- **Ne yapıldı?** Kayıt olma, giriş yapma, 2FA (iki adımlı doğrulama), token yenileme ve çıkış yapma gibi istekler, FR-001, FR-002 gibi ölçülebilir fonksiyonel gereksinimlere dönüştürüldü ve `spec.md` dosyasına yazıldı.
- **Mantığı:** Hangi koşullarda girişin başarılı sayılacağı veya token süresinin nasıl yönetileceği gibi "kabul senaryoları"nın kodlamaya geçilmeden önce kesin bir şekilde belirlenmesi.

## 3. Clarify (Netleştirme) Aşaması
**Soru:** *Auth spesifikasyonunda açıkta kalan, çelişen veya belirsiz olan noktalar var mı?*

Spesifikasyon oluşturulduktan sonra olası mantıksal boşlukların sorgulandığı interaktif aşamadır.
- **Ne yapıldı?** Sistem; "Şifre yanlış girildiğinde hesap kilitlenecek mi?", "Oturum süresi dolduğunda kullanıcıya tam olarak ne gösterilecek?" gibi Auth sürecine özel sorular sorarak eksik noktaları tespit etti. Alınan cevaplar (örn: Hesap kilitleme yok, sadece 5/dk sınır var) `spec.md` dosyasına entegre edildi.
- **Mantığı:** Geliştirme sırasında şifre doğrulama kurallarında tereddüt yaşamamak için tüm ürün kararlarının baştan netleştirilmesi.

## 4. Plan (Teknik Tasarım ve Planlama) Aşaması
**Soru:** *Bu Auth spesifikasyonu, teknik koda nasıl dökülecek?*

Auth modülü için kodlama stratejisinin ve veri modellerinin tasarlandığı aşamadır.
- **Ne yapıldı?** `LoginRequest`, `AuthSession` gibi veri modelleri, API isteklerini yönetecek repository sınıfları ve arkaplanda çalışacak (interceptors) token yenileme mekanizmasının teknik haritası çıkartılarak `plan.md` dosyası oluşturuldu.
- **Mantığı:** Mimari zorlukların (örneğin token yenileme isteğinin uygulamayı dondurmadan arka planda nasıl yapılacağı) kod yazılırken değil, önceden planlanarak çözülmesi.

## 5. Tasks (Görevlendirme) Aşaması
**Soru:** *Planı hayata geçirmek için hangi adımları izlemeliyiz?*

Oluşturulan Auth tasarım planının uygulanabilir küçük görevlere bölündüğü aşamadır.
- **Ne yapıldı?** Auth geliştirme süreci en küçük mantıksal birimlere bölündü (T001'den T043'e kadar) ve bağımlılık sırasına göre dizilerek `tasks.md` dosyasına yazıldı.
- **Mantığı:** Önce token saklama mekanizmasının (Secure Storage), ardından ağ katmanının (Dio), en son ise arayüzlerin (UI) geliştirilmesi gibi mantıksal bir sıranın (kaos yaratmadan) takip edilmesi.

## 6. Implement (Uygulama/Kodlama) Aşaması
**Soru:** *Görev listesindeki adımlar koda nasıl dönüşüyor?*

Auth modülü için planlanan mimarinin gerçek kodlara dönüştüğü aşamadır.
- **Ne yapıldı?** `tasks.md` içerisindeki her bir görev (örn: Sadece `RegisterCubit` sınıfını yazmak) sırasıyla okundu, kodlandı ve yapılan her görev `[x]` işaretiyle tamamlandı olarak işaretlendi.
- **Mantığı:** Geliştirici (veya yapay zeka), büyük resmi düşünmek zorunda kalmaz. Yalnızca o anki küçük göreve odaklanır. Bir görev bitmeden diğerine geçilmediği için Auth gibi kritik bir modülde bağlam kaybı önlenir.

## 7. Converge (Analiz ve Yakınsama) Aşaması
**Soru:** *Yazılan Auth kodları, başta belirlediğimiz spesifikasyon ve planla tam olarak eşleşiyor mu?*

Kodun, kendisinden beklenen belgelere göre denetlendiği son doğrulama aşamasıdır.
- **Ne yapıldı?** Projedeki kodlar okundu ve Auth spesifikasyonu ile karşılaştırıldı. İnceleme sonucunda unutulan "Ana ekrana yönlendirme eksiği" veya "Çıkış Yap butonunun UI'a eklenmemesi" gibi eksikler tespit edildi. Bu eksikler `tasks.md` dosyasına yeni görevler olarak eklendi ve tamamlandı.
- **Mantığı:** İstekler ile gerçekleşen kod arasındaki boşluk (gap) bulunana ve tamamen kapatılana kadar sürecin devam etmesi (Otomatik QA / Sağlama).

---

### Özetle Geliştirme Felsefesi (The Core Philosophy)
Auth & Session özelliğinin geliştirilmesinde izlenen ana mantık **"Düşünmeyi ve Uygulamayı Birbirinden Ayırmaktır"**. 
1. Auth sürecinin nasıl işleyeceği konuşuldu (Spec).
2. Teknik mimarisi tasarlandı (Plan).
3. Hangi adımlarla yapılacağı listelendi (Tasks).
4. Listelenen adımlar koda döküldü (Implement). 
5. Son olarak kodun, Auth istekleriyle %100 uyuşup uyuşmadığı kontrol edildi (Converge).

Bu disiplin sayesinde Auth özelliği için neyin, nerede ve neden yapıldığı her zaman belgelenmiş ve takip edilebilir durumdadır.
