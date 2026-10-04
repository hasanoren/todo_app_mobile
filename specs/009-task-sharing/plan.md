# Implementation Plan: FEAT-09 — Task Sharing & Member Access

**Feature Branch**: `009-task-sharing`  
**Spec**: [specs/009-task-sharing/spec.md](spec.md)

---

## 1. Architecture & Layering

### 1.1 Data Layer (`lib/features/task_shares/data/`)
- `models/share_task_request.dart`: DTO with `email` field and JSON serialization.
- `models/share_task_response_dto.dart`: Response DTO with `message`.
- `models/shares_collection_response_dto.dart`: Unpaginated list wrapper for `SharedUserItemDto`.
- `datasources/task_shares_remote_data_source.dart`:
  - `Future<List<SharedUserItemDto>> getTaskShares(String taskId)`
  - `Future<String> shareTask(String taskId, String email)`
  - `Future<void> removeCollaborator(String taskId, String userId)`
  - `Future<void> leaveSharedTask(String taskId)`
- `repositories/task_shares_repository_impl.dart`: Concrete implementation handling Dio errors.

### 1.2 Domain Layer (`lib/features/task_shares/domain/`)
- `repositories/task_shares_repository.dart`: Clean domain repository interface.

### 1.3 State Management (`lib/features/task_shares/presentation/cubits/`)
- `task_shares_cubit.dart` & `task_shares_state.dart`:
  - `loadShares(String taskId)`
  - `shareTask(String taskId, String email)`
  - `removeCollaborator(String taskId, String userId)`
  - `leaveSharedTask(String taskId)`

### 1.4 Presentation & UI (`lib/features/task_shares/presentation/`)
- `widgets/share_task_dialog.dart`: Dialog with email textfield and validation.
- `widgets/task_shares_section.dart`: Embedded section in `TaskDetailScreen` showing:
  - Header with collaborator count
  - "Kişi Ekle" button (owner only)
  - List of collaborators with avatars, emails, shared date, and remove buttons (owner only)
  - "Paylaşımdan Ayrıl" button (collaborator only)
- Visual cues in `TaskCard`:
  - Badge showing "Paylaşıldı" when `!isOwner`
  - Collaborators count indicator when `isOwner && sharedWith.isNotEmpty`

### 1.5 Integration & DI
- Add endpoints to `ApiConstants`:
  - `taskShares(taskId)`
  - `taskShareUser(taskId, userId)`
  - `taskShareMe(taskId)`
- Register `TaskSharesRepository` in `main.dart` `MultiRepositoryProvider`.
- Unit tests in `test/features/task_shares/task_shares_test.dart`.

