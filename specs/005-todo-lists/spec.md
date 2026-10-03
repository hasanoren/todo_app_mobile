# Feature Specification: FEAT-05 — Todo Lists (Görev Listeleri)

**Feature Branch**: `005-todo-lists`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User description: "FEAT-05: Todo Lists" (from docs/feature-breakdown.md and docs/spec.md)

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Görev Listelerini Görüntüleme (Priority: P1)

Giriş yapmış kullanıcı, görev listelerini renk göstergeleri, isimleri ve detaylarıyla birlikte ana ekranda veya listeler sekmesinde kartlar halinde görüntüler.

**Why this priority**: Görev listeleri, görevlerin (FEAT-06) kategorize edileceği ve gruplanacağı temel çalışma alanıdır. Kullanıcının mevcut listelerini görmesi tüm todo akışının ön koşuludur.

**Independent Test**: Uygulamada Listeler ekranı açıldığında `GET /api/TodoLists` çağrılır; sunucudan gelen `CollectionResponse<TodoListResponse>` ayrıştırılarak kullanıcının listeleri renkli etiketleri ve isimleriyle listelenir. Liste yoksa kullanıcı dostu "Henüz liste oluşturmadınız" boş ekranı gösterilir.

**Acceptance Scenarios**:

1. **Given** kullanıcı oturum açmış, **When** Listeler ekranını açtığında, **Then** `GET /api/TodoLists` çağrılır ve `items` listesindeki her liste renk kodu ve adıyla ekranda görüntülenir.
2. **Given** kullanıcının henüz hiç listesi yoksa, **When** ekran yüklendiğinde, **Then** kullanıcıya yeni liste oluşturmaya yönlendiren boş durum (empty state) tasarımı gösterilir.
3. **Given** kullanıcı listeyi aşağı çektiğinde (pull-to-refresh), **Then** listeler sunucudan yeniden yüklenir.
4. **Given** ağ hatası meydana geldiğinde, **Then** kullanıcıya bilgilendirici bir hata mesajı ve "Yeniden Dene" butonu sunulur.

---

### User Story 2 - Yeni Görev Listesi Oluşturma (Priority: P1)

Kullanıcı yeni bir çalışma alanı/kategori açmak istediğinde "Yeni Liste" butonuna dokunur; liste adını girer, sunulan şık renk paletinden (veya özel renk) bir renk seçer ve listesini kaydeder.

**Why this priority**: Kullanıcıların görevlerini ayrıştırabilmesi (örneğin "İş", "Kişisel", "Alışveriş") için liste oluşturabilmesi birincil fonksiyondur.

**Independent Test**: "Yeni Liste Ekle" butonuna basılır, modal bottom sheet açılır. İsim ("İş Projeleri") ve renk ("#3B82F6") seçilip onaylandığında `POST /api/TodoLists` çağrılır; 201 Created yanıtı ile dönen liste koleksiyona eklenir ve modal kapanır.

**Acceptance Scenarios**:

1. **Given** kullanıcı yeni liste modalını açtığında, **When** geçerli bir liste adı (1-100 karakter arası) ve renk seçip kaydettiğinde, **Then** `POST /api/TodoLists` çağrılır, yeni liste listeye eklenir ve başarı bildirimi gösterilir.
2. **Given** kullanıcı liste adını boş bıraktığında veya yalnızca boşluk girdiğinde, **Then** kaydet butonu engellenir veya "Liste adı boş bırakılamaz" validasyon uyarısı verilir.
3. **Given** kullanıcı renk seçmediğinde, **Then** varsayılan bir tema rengi (ör. `#6366F1`) atanarak kayıt tamamlanır.

---

### User Story 3 - Görev Listesini Düzenleme (Priority: P2)

Kullanıcı mevcut bir listenin adını veya rengini değiştirmek istediğinde liste kartındaki "Düzenle" seçeneğini kullanır; güncel bilgileri girip kaydeder.

**Why this priority**: Kullanıcıların değişen ihtiyaçlarına göre listelerini yeniden adlandırabilmesi ve görsel olarak organize edebilmesi esneklik sağlar.

**Independent Test**: Listenin seçenekler menüsünden "Düzenle" seçilir, mevcut isim ve renk formda hazır gelir. Yeni değerler girilip kaydedildiğinde `PUT /api/TodoLists/{id}` çağrılır ve arayüzdeki liste anında güncellenir.

**Acceptance Scenarios**:

1. **Given** kullanıcı düzenleme formunu açtığında, **When** yeni bir isim veya renk seçip onayladığında, **Then** `PUT /api/TodoLists/{id}` çağrılır ve liste bilgisi yerel listede anında güncellenir.
2. **Given** sunucudan güncelleme hatası döndüğünde, **Then** kullanıcıya hata snackbar'ı gösterilir ve form açık bırakılarak tekrar deneme imkanı verilir.

---

### User Story 4 - Görev Listesini Silme (Priority: P2)

Kullanıcı artık ihtiyaç duymadığı bir görev listesini silmek istediğinde silme aksiyonunu tetikler ve onay diyalogunda işlemi onaylayarak listeyi sistemden kaldırır.

**Why this priority**: Gereksiz listelerin temizlenmesi kullanıcı arayüzünün düzenli kalmasını sağlar.

**Independent Test**: Liste kartında "Sil" butonuna basıldığında onay diyalogu gösterilir ("Bu listeyi silmek istediğinize emin misiniz?"). Onaylandığında `DELETE /api/TodoLists/{id}` çağrılır; 204 No Content yanıtı alındığında liste ekrandan kaldırılır.

**Acceptance Scenarios**:

1. **Given** kullanıcı silme butonuna bastığında, **When** onay penceresinde "Sil" butonuna bastığında, **Then** `DELETE /api/TodoLists/{id}` çağrılır ve ilgili liste yerel durumdan çıkarılır.
2. **Given** kullanıcı onay penceresinde "Vazgeç" butonuna bastığında, **Then** hiçbir API çağrısı yapılmaz ve liste silinmez.

---

## Edge Cases

- **Renk Kodu Biçimi:** Sunucu maksimum 7 karakterlik hex renk kodlarını kabul eder (örn: `#FF5733`). Renk seçici sadece geçerli `#RRGGBB` formatında değerler üretmelidir.
- **Liste Adı Uzunluğu:** Liste adı maksimum 100 karakter olmalıdır; 100 karakteri aşan girişler engellenmelidir.
- **Yetkisiz Erişim (401/403):** Token süresi dolmuşsa otomatik yenileme (interceptor) devreye girmeli; oturum düşmüşse kullanıcı Login ekranına güvenle yönlendirilmelidir.
- **Hızlı Ardışık Tıklamalar (Double-submit):** Kaydetme ve silme butonları işlem sürerken `disabled` duruma geçerek yinelenen API isteklerini önlemelidir.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistem, yalnızca oturum açmış kullanıcıların görev listelerine erişmesine ve işlem yapmasına izin vermelidir.
- **FR-002**: Sistem, `GET /api/TodoLists` endpoint'i üzerinden kullanıcının tüm listelerini `CollectionResponse<TodoListResponse>` formatında çekmelidir.
- **FR-003**: Sistem, yeni liste oluşturmak için `POST /api/TodoLists` endpoint'ine `{ "name": "...", "colorCode": "..." }` gövdesiyle istek göndermelidir.
- **FR-004**: Sistem, liste güncellemesi için `PUT /api/TodoLists/{id}` endpoint'ini kullanmalıdır.
- **FR-005**: Sistem, liste silme işlemi için `DELETE /api/TodoLists/{id}` endpoint'ine istek atmalı ve 204 No Content yanıtında listeyi yerel state'ten kaldırmalıdır.
- **FR-006**: Sistem, liste adı için en az 1, en fazla 100 karakter sınırını doğrulamalıdır.
- **FR-007**: Sistem, kullanıcıya popüler renk paletlerini (En az 8 adet Material Renk: Kırmızı, Mavi, Yeşil, Turuncu, Mor, Pembe, Teal, Indigo) hızlı seçim için sunmalıdır.

---

### Key Entities

- **TodoList**: `id` (UUID), `name` (string), `colorCode` (string?), `ownerId` (UUID), `createdAt` (DateTime), `updatedAt` (DateTime?).
- **CreateTodoListRequest**: `name` (string, max 100), `colorCode` (string?, max 7).
- **UpdateTodoListRequest**: `name` (string, max 100), `colorCode` (string?, max 7).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Kullanıcının görev listeleri ekran açıldıktan sonra 1 saniyenin altında yüklenmelidir.
- **SC-002**: Yeni liste oluşturma, düzenleme ve silme işlemleri yerel state'e anında yansımalıdır.
- **SC-003**: Renk seçim bileşeni tek dokunuşla seçilebilmeli ve hex kod dönüşümü %100 hatasız olmalıdır.
- **SC-004**: Kod analizi (`flutter analyze`) 0 hata/uyarı vermeli ve tüm yeni birim/widget testleri başarıyla geçmelidir.
