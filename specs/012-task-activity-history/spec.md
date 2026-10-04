# Feature Specification: FEAT-12 — Görev Aktivite Geçmişi (Task Activity History)

**Feature Branch**: `012-task-activity-history`  
**Created**: 2026-10-04  
**Status**: Ready for Implementation  
**Input**: Feature breakdown FEAT-12 from `docs/spec.md` & `docs/feature-breakdown.md`

---

## Overview

Kullanıcılar bir görev üzerinde çalıştıklarında veya bir görevi iş birliği için paylaştıklarında, görev üzerinde hangi işlemlerin yapıldığını (görevin oluşturulması, başlık/açıklama güncellenmesi, tamamlanması veya geri alınması, etiket eklenmesi, alt görev oluşturulması, kullanıcılarla paylaşılması veya sahipliğinin devredilmesi) kronolojik olarak görmek isterler.

FEAT-12, `GET /api/TodoItems/{id}/activities` endpoint'ini kullanarak:
1. Görev detay ekranına (`TaskDetailScreen`) şık bir **"Aktivite Geçmişi" (Activity History / Audit Trail)** zaman çizelgesi bölümü ekler.
2. İşlemi yapan kullanıcının e-postasını (`userEmail`), yapılan eylemi (`action`), detay açıklamasını (`details`) ve işlem zamanını (`createdAt`) kronolojik olarak görüntüler.
3. Hem görev sahibi hem de paylaşılan kullanıcılar tarafından görüntülenebilir.
4. Yenileme (Refresh) ve boş durum (Empty State) desteği sağlar.

---

## User Scenarios & Acceptance Criteria

### User Story 1 - Görev Aktivite Geçmişini Görüntüleme (Priority: P1)
Bir görev sahibi veya paylaşılan iş birliği kullanıcısı olarak, görev detay ekranında görevin tüm geçmiş hareketlerini ve değişikliklerini zaman çizelgesi şeklinde görmek istiyorum.

**Acceptance Criteria**:
1. `TaskDetailScreen` üzerinde "Aktiviteler" (Aktivite Geçmişi) adında özel bir bölüm/kart yer alır.
2. Sayfa açıldığında veya yenilendiğinde `GET /api/TodoItems/{taskId}/activities` çağrılır.
3. Gelen aktiviteler en yeniden en eskiye veya kronolojik sırada zaman çizelgesi (timeline) tasarımıyla listelenir.
4. Her aktivite öğesinde:
   - Eylem türüne uygun bir ikon (örn. oluşturma, güncelleme, tamamlama, paylaşma, silme)
   - İşlemi yapan kullanıcı (`userEmail`)
   - Eylem adı veya açıklaması (`action`)
   - Varsa detay metni (`details`)
   - İşlem tarihi/saati (`AppDateFormat` ile biçimlendirilmiş)
   görüntülenir.
5. Henüz hiçbir aktivite yoksa *"Bu görev için henüz bir aktivite kaydı bulunmuyor."* boş durum mesajı gösterilir.
6. Yükleme esnasında yükleme animasyonu (CircularProgressIndicator) ve hata durumunda hata mesajı ile "Tekrar Dene" butonu gösterilir.

---

## Data Schema & API Contract

### Endpoint:
`GET /api/TodoItems/{id}/activities`
- **Yetkilendirme:** Bearer Token (görev sahibi veya paylaşılan kullanıcı)
- **Başarılı Yanıt (200 OK):** `CollectionResponse<TodoItemActivityResponse>` veya `List<TodoItemActivityResponse>`:
```json
[
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "userEmail": "user@example.com",
    "action": "Created",
    "details": "Görev oluşturuldu",
    "createdAt": "2026-10-04T12:00:00Z"
  }
]
```

---

## Success Criteria

1. Görev detay sayfasında aktiviteler hatasız ve gecikmesiz olarak listelenir.
2. Tüm veri dönüştürme ve hata durumları güvenli bir şekilde ele alınır.
3. Birim ve widget testleri %100 başarıyla geçer.
4. Kod analizi `dart analyze` 0 uyarı/hata verir.
