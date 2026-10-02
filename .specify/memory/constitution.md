<!-- SYNC IMPACT REPORT
Version change: 0.0.0 → 1.0.0
Bump rationale: MAJOR — Initial constitution ratification for the TodoApp Mobile project.

Added sections:
  - Core Principles (7 principles defined)
  - Technology Stack & Constraints
  - Development Workflow & Quality Gates
  - Governance

Removed sections: None (first version)

Modified principles: None (first version)

Follow-up TODOs: None
-->

# TodoApp Mobile Constitution

## Core Principles

### I. API-First Consumer

Bu uygulama mevcut bir .NET Web API'nin **tüketici istemcisidir**. Backend davranışı
[`docs/spec.md`](../../docs/spec.md) tarafından tanımlanır ve kaynak doğruluk belgesi olarak
kabul edilir.

- Uygulama backend kodu üretmez, değiştirmez veya varsayımsal endpoint'ler icat etmez.
- API spesifikasyonunda belgelenmeyen bir davranışla karşılaşıldığında, varsayım yapmak yerine
  açıkça belirsizlik (ambiguity) olarak işaretlenmeli ve açıklama talep edilmelidir.
- Tüm veri modelleri, enum değerleri ve iş kuralları API spesifikasyonundan türetilmelidir.

### II. Feature-Isolated Architecture

Her feature bağımsız, kendi kendine yeten bir modül olarak yapılandırılmalıdır.

- Klasör yapısı `lib/features/<feature_name>/` altında organize edilmelidir.
- Her feature kendi `data/`, `domain/`, ve `presentation/` katmanlarını içermelidir.
- Feature'lar arası doğrudan import yapılmamalıdır; paylaşılan kod `lib/core/` altında
  tutulmalıdır.
- Yeni bir feature eklemek, mevcut feature kodlarında değişiklik gerektirmemelidir.

### III. Bloc-Driven State Management

State yönetimi için **Flutter Bloc** kullanılmalıdır.

- Her feature'ın kendi Bloc/Cubit'i olmalıdır; global state paylaşımı yalnızca `AuthBloc`
  gibi altyapı Bloc'ları aracılığıyla yapılmalıdır.
- Bloc event'leri açık, tanımlayıcı isimlerle adlandırılmalıdır
  (örn: `TodoItemsLoadRequested`, `TodoItemCompleteToggled`).
- Bloc state'leri immutable olmalı, `Equatable` kullanılmalı ve `sealed class` veya
  `freezed` ile türetilmelidir.
- SignalR olayları doğrudan Bloc event'lerine dönüştürülmelidir.
- UI katmanı iş mantığı içermemelidir; tüm mantık Bloc/Cubit içinde kalmalıdır.

### IV. Dio-Powered Network Layer

HTTP iletişimi için **Dio** kullanılmalıdır.

- Tek bir merkezi `Dio` instance'ı `lib/core/network/` altında yapılandırılmalıdır.
- Auth interceptor: `Authorization: Bearer <token>` header'ını tüm korumalı isteklere
  otomatik ekler.
- Token refresh interceptor: `401 Unauthorized` yanıtlarında mutex-korumalı token yenileme
  yapılmalı ve başarısız istek yeniden denenmelidir.
- RFC 7807 hata yanıtları (`type`, `title`, `status`, `detail`, `errors`) tutarlı bir
  şekilde ayrıştırılmalı ve kullanıcıya anlamlı mesajlar olarak sunulmalıdır.
- Rate limit (`429`) yanıtları kullanıcıya bildirilmeli ve uygun geri çekilme (backoff)
  stratejisi uygulanmalıdır.

### V. Secure Token Lifecycle

JWT access token ve refresh token güvenli bir şekilde yönetilmelidir.

- Token'lar `flutter_secure_storage` kullanılarak platform keychain/keystore'da saklanmalıdır.
- Access token'lar **60 dakika** süreyle geçerlidir; süresi dolmadan proaktif olarak
  yenilenmelidir.
- Refresh token'lar tek kullanımlıktır; yeni çift alındığında eski token geçersiz olur.
- Logout işlemi hem sunucu tarafında (`POST /api/Auth/logout`) revoke yapmalı hem de
  istemci tarafında tüm yerel depolamayı temizlemelidir.
- Token'lar SharedPreferences veya düz metin dosyalarında saklanmamalıdır.

### VI. Spec-Driven Development Workflow

Geliştirme süreci GitHub Spec Kit iş akışına uygun olarak yürütülmelidir.

- Her feature için sırasıyla: `specify` → `plan` → `tasks` → `implement` adımları
  izlenmelidir.
- Spesifikasyon ve plan onaylanmadan kodlama başlatılmamalıdır.
- Feature breakdown dokümanı (`docs/feature-breakdown.md`) tüm API endpoint'lerini
  eksiksiz olarak eşleştirmelidir.
- Belirsizlikler (Q1–Q10) sessizce çözülmemeli, açıkça belgelenmeli ve onay alınmalıdır.

### VII. Simplicity & YAGNI

Uygulama basit tutulmalı ve ihtiyaç duyulmayan karmaşıklıktan kaçınılmalıdır.

- API spesifikasyonunda bulunmayan özellikler eklenmemelidir.
- Offline-first sync gibi belgelenmemiş backend protokolleri icat edilmemelidir; read-cache
  kullanımı (Hive) ile network-first strateji uygulanmalıdır.
- Mevcut sorunu çözen en basit yaklaşım tercih edilmelidir.
- Erken optimizasyon yerine önce doğru çalışan, sonra performanslı kod hedeflenmelidir.

## Technology Stack & Constraints

### Core Framework & Language
- **Flutter** (stable channel) — Cross-platform mobil uygulama
- **Dart** (Flutter SDK ile birlikte gelen versiyon)
- **Minimum Platform:** Android API 21+, iOS 13+ (varsayılan Flutter destekleri)

### Key Dependencies
| Concern | Package | Purpose |
|---------|---------|---------|
| State Management | `flutter_bloc` / `bloc` | Event-driven state yönetimi |
| HTTP Client | `dio` | API iletişimi, interceptor'lar |
| Routing | `go_router` | Deklaratif navigasyon, deep link desteği |
| Secure Storage | `flutter_secure_storage` | JWT token'ların güvenli depolanması |
| Read Cache | `hive` / `hive_flutter` | Network-first ile yerel read-cache |
| SignalR | `signalr_netcore` | Gerçek zamanlı WebSocket bağlantısı |
| Equatable | `equatable` | Bloc state karşılaştırması |
| JSON Serialization | `json_serializable` / `json_annotation` | Model sınıfları için kod üretimi |
| Code Generation | `build_runner` | `json_serializable` ve `freezed` için |
| QR Code | `qr_flutter` | 2FA QR kod gösterimi |

### Architecture Pattern
- **Feature-First** klasör yapısı ile Clean Architecture katmanları:
  ```
  lib/
  ├── core/                  # Paylaşılan altyapı
  │   ├── network/           # Dio client, interceptor'lar, API error handler
  │   ├── storage/           # Secure storage, Hive cache
  │   ├── router/            # GoRouter yapılandırması, auth guard
  │   ├── theme/             # Material 3 tema tanımları
  │   ├── models/            # Paylaşılan response wrapper'ları (PaginatedResponse, vb.)
  │   └── signalr/           # SignalR bağlantı servisi
  ├── features/
  │   ├── auth/              # FEAT-01: Authentication
  │   │   ├── data/          # Repository, data source, model
  │   │   ├── domain/        # Entity, use case (gerekirse)
  │   │   └── presentation/  # Bloc, screens, widgets
  │   ├── password_recovery/ # FEAT-02
  │   ├── two_factor_auth/   # FEAT-03
  │   └── ...
  └── main.dart
  ```

### UI & Design
- **Material 3** tema sistemi kullanılmalıdır.
- Projeye özel marka renkleri ve tipografi tanımları `lib/core/theme/` altında
  merkezi olarak tutulmalıdır.
- Todo List renk kodları (`colorCode`) dinamik olarak Material 3 `ColorScheme`
  ile uyumlu şekilde uygulanmalıdır.

### Localization
- Uygulama dili **yalnızca Türkçe** olacaktır.
- Tüm kullanıcıya görünen string'ler `lib/core/constants/` altında merkezi
  sabit dosyalarında tutulmalıdır. Gelecekte l10n altyapısına geçiş kolaylaştırılmalıdır.

## Development Workflow & Quality Gates

### Testing Strategy
- **Kritik iş mantığı** için unit test yazılmalıdır:
  - Bloc/Cubit test'leri (state geçişleri)
  - Repository/Data Source test'leri (API çağrı mantığı)
  - Token refresh ve hata işleme interceptor test'leri
- Her test dosyası ilgili kaynak dosyasıyla aynı dizin yapısını izlemelidir:
  `test/features/<feature>/...`
- Widget test'leri isteğe bağlıdır; kritik akışlar (login, task creation) için
  önerilir.

### Code Quality
- `analysis_options.yaml` dosyası strict lint kurallarını içermelidir
  (`flutter_lints` veya özel yapılandırma).
- Tüm public API'ler (sınıf, metod, parametre) Dart doc yorumları ile
  belgelenmelidir.
- Kullanılmayan import'lar, değişkenler ve dead code temizlenmelidir.

### Version Control
- Git commit mesajları [Conventional Commits](https://www.conventionalcommits.org/)
  formatına uymalıdır:
  - `feat:` yeni özellik
  - `fix:` hata düzeltme
  - `docs:` dokümantasyon
  - `refactor:` yapısal iyileştirme
  - `test:` test ekleme/düzeltme
- Her feature için ayrı Git branch'i oluşturulmalıdır.

## Governance

Bu anayasa, TodoApp Mobile projesi için tüm geliştirme kararlarının temel
referans belgesidir.

- Anayasa ile çelişen kod değişiklikleri yapılmamalıdır.
- Anayasa güncellemeleri Spec Kit `speckit-constitution` komutu aracılığıyla
  yapılmalı ve semantic versioning ile takip edilmelidir:
  - **MAJOR**: İlke kaldırma veya köklü değişiklik
  - **MINOR**: Yeni ilke ekleme veya mevcut ilkeyi genişletme
  - **PATCH**: İfade düzeltmeleri, açıklamalar
- Her anayasa değişikliği bir Sync Impact Report içermeli ve kullanıcı
  onayından geçmelidir.
- Karmaşıklık ekleyen her karar, açık bir gerekçe ile belgelenmelidir.

**Version**: 1.0.0 | **Ratified**: 2026-10-01 | **Last Amended**: 2026-10-01
