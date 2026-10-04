# Feature Specification: FEAT-11 — Çöp Kutusu & Geri Yükleme (Trash & Recycle Bin)

**Feature Branch**: `011-trash-bin`  
**Created**: 2026-10-04  
**Status**: Ready for Implementation  
**Input**: User inquiry: "silinen görevler'in gittiği çöp kutusu nerede görünmüyor arayüzde"

---

## Overview

Kullanıcılar görev sildiklerinde backend bu görevleri `IsDeleted = true` olarak işaretleyip çöp kutusuna taşımaktadır (`soft delete`). Ancak mobil arayüzde kullanıcının çöp kutusuna erişebileceği, silinen görevleri görebileceği, yanlışlıkla silinenleri geri yükleyebileceği veya kalıcı olarak silebileceği bir ekran bulunmamaktadır.

FEAT-11, bu eksikliği gidererek:
1. `Çöp Kutusu` ekranını (`TrashScreen`),
2. Silinen görevleri sayfalı olarak listelemeyi (`GET /api/TodoItems/trash`),
3. Görevleri aktif listeye geri yüklemeyi (`POST /api/TodoItems/{id}/restore`),
4. Görevleri kalıcı olarak sistemden kaldırmayı (`DELETE /api/TodoItems/{id}/permanent`),
5. Ana ekran ve Görevler ekranı üzerinden Çöp Kutusu'na kolay erişim navigasyonunu sağlar.

---

## User Scenarios & Acceptance Criteria

### User Story 1 - Çöp Kutusunu Görüntüleme (Priority: P1)
Bir kullanıcı olarak, sildiğim görevleri liste halinde görebileceğim özel bir çöp kutusu ekranına erişmek istiyorum.

**Acceptance Criteria**:
1. `TasksScreen` ve `HomeScreen` üzerinden Çöp Kutusu ekranına (`/trash`) geçiş bağlantısı (AppBar menü/aksiyon butonu) bulunur.
2. `TrashScreen` açıldığında `GET /api/TodoItems/trash` çağrılır ve silinen görevler listelenir.
3. Listede her görev için başlık, silinme tarihi (`deletedAt`), öncelik ve açıklama önizlemesi görüntülenir.
4. Çöp kutusu boş olduğunda açıklayıcı bir boş durum ("Çöp Kutusu Boş - Silinen görevler burada listelenir") gösterilir.
5. Sayfayı aşağı kaydırarak yenileme (Pull-to-refresh) ve sonsuz kaydırma/sayfalama (Infinite scrolling) desteklenir.

---

### User Story 2 - Görevi Geri Yükleme (Restore) (Priority: P1)
Bir kullanıcı olarak, yanlışlıkla sildiğim bir görevi çöp kutusundan tek dokunuşla geri getirmek istiyorum.

**Acceptance Criteria**:
1. Çöp kutusundaki her kartta belirgin bir "Geri Yükle" (`Icons.restore_from_trash` / `Icons.undo`) aksiyonu bulunur.
2. Butona basıldığında `POST /api/TodoItems/{id}/restore` endpoint'i tetiklenir.
3. Başarılı yanıtta görev çöp kutusu listesinden hemen kaldırılır ve kullanıcıya `"'{görev}' geri yüklendi"` bildirim mesajı (SnackBar) gösterilir.
4. Kullanıcı ana görev listesine döndüğünde geri yüklenen görev aktif görevler arasında yer alır.

---

### User Story 3 - Görevi Kalıcı Olarak Silme (Permanent Delete) (Priority: P1)
Bir kullanıcı olarak, artık kesinlikle ihtiyaç duymadığım silinmiş görevleri kalıcı olarak yok etmek istiyorum.

**Acceptance Criteria**:
1. Çöp kutusundaki her kartta "Kalıcı Sil" (`Icons.delete_forever`) butonu bulunur.
2. Tıklandığında kullanıcıya onay iletişim kutusu (Confirmation Dialog) gösterilir: *"Bu işlem geri alınamaz. Görevi kalıcı olarak silmek istediğinize emin misiniz?"*
3. Kullanıcı onayladığında `DELETE /api/TodoItems/{id}/permanent` endpoint'i çağrılır.
4. Başarılı yanıtta görev listeden kaldırılır ve `"Görev kalıcı olarak silindi"` bildirimi gösterilir.

---

## Success Criteria

1. Kullanıcı çöp kutusundaki bir görevi en fazla 2 adımda geri yükleyebilir.
2. Kalıcı silme işlemi onay diyaloğu olmadan asla gerçekleşmez.
3. Çöp kutusundaki tüm işlemler (yükleme, geri alma, kalıcı silme) hatasız çalışır ve tüm birim testleri %100 başarılı olur.
