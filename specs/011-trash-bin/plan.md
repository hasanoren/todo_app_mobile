# Implementation Plan: FEAT-11 — Çöp Kutusu & Geri Yükleme (Trash & Recycle Bin)

**Feature Branch**: `011-trash-bin`  
**Spec**: [specs/011-trash-bin/spec.md](spec.md)

---

## 1. Architecture & Layering

### 1.1 API Constants (`lib/core/constants/api_constants.dart`)
- `static const String todoItemsTrash = '/api/TodoItems/trash';`
- `static String todoItemRestore(String id) => '/api/TodoItems/$id/restore';`
- `static String todoItemPermanent(String id) => '/api/TodoItems/$id/permanent';`

### 1.2 Data & Domain Layer (`lib/features/tasks/`)
- In `TodoItemsRemoteDataSource`:
  - `Future<PaginatedResponseDto<TodoItemResponseDto>> getTrashItems({int page = 1, int pageSize = 20});`
  - `Future<TodoItemResponseDto> restoreTodoItem(String id);`
  - `Future<void> permanentDeleteTodoItem(String id);`
- In `TodoItemsRepository` & `TodoItemsRepositoryImpl`:
  - Interface contracts and implementations mapping errors to `ServerFailure` / `NetworkFailure`.

### 1.3 State Management (`lib/features/tasks/presentation/cubits/`)
- `TrashCubit` & `TrashState`:
  - State: `initial`, `loading`, `loaded`, `actionInProgress`, `error`.
  - Properties: `items`, `page`, `totalPages`, `hasMore`, `errorMessage`, `successMessage`.
  - Methods:
    - `loadTrash({bool refresh = false})`
    - `loadMore()`
    - `restoreItem(String id)`
    - `permanentDeleteItem(String id)`

### 1.4 Presentation Layer (`lib/features/tasks/presentation/`)
- `widgets/trash_task_card.dart`:
  - Displays title, description, deletion time, priority badge.
  - Action buttons: "Geri Yükle" (Undo/Restore) and "Kalıcı Sil" (Delete Forever).
- `screens/trash_screen.dart`:
  - Scaffold with AppBar "Çöp Kutusu".
  - ListView with Pull-to-refresh and infinite scroll.
  - Confirmation dialog for permanent delete.
  - Empty state when trash is empty.

### 1.5 Navigation & AppRouter
- Add `RouteNames.trash = '/trash'`.
- Register `/trash` in `AppRouter`.
- Add Çöp Kutusu navigation icon in `TasksScreen` and `HomeScreen`.

### 1.6 Verification & Testing
- Unit tests for `TrashCubit` and repository methods in `test/features/tasks/trash_test.dart`.
- Ensure 0 analyzer issues via `dart analyze lib test`.
- Run all test suites with `flutter test`.
- Build debug APK and install on Samsung Galaxy A71 via ADB.
