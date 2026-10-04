# Implementation Plan: FEAT-08 — Tags & Categorization

**Feature Branch**: `008-tags-categorization`  
**Spec**: [specs/008-tags/spec.md](spec.md)

---

## 1. Architecture & Layering

### 1.1 Data Layer (`lib/features/tags/data/`)
- `models/tag_response_dto.dart`: `TagResponseDto` with JSON serialization.
- `models/tags_collection_response_dto.dart`: Unpaginated list wrapper.
- `models/create_tag_request.dart`: DTO for admin tag creation.
- `datasources/tags_remote_data_source.dart`:
  - `Future<List<TagResponseDto>> getSystemTags()`
  - `Future<TagResponseDto> createTag(CreateTagRequest request)`
  - `Future<PaginatedTodoItemsResponseDto> getTasksByTag(String tagId, {int page = 1, int pageSize = 20})`
  - `Future<List<TagResponseDto>> getTaskTags(String taskId)`
  - `Future<void> attachTagToTask(String taskId, String tagId)`
  - `Future<void> detachTagFromTask(String taskId, String tagId)`
- `repositories/tags_repository_impl.dart`: Concrete implementation handling Dio errors and mapping to domain.

### 1.2 Domain Layer (`lib/features/tags/domain/`)
- `repositories/tags_repository.dart`: Interface definition.

### 1.3 State Management (`lib/features/tags/presentation/cubits/`)
- `tags_cubit.dart` & `tags_state.dart`:
  - Load system tags
  - Load task tags for a specific task
  - Attach tag to task (optimistic or reactive update)
  - Detach tag from task
  - Create tag (Admin only)
- `tagged_tasks_cubit.dart` & `tagged_tasks_state.dart`:
  - Infinite scroll loading of tasks tagged with `tagId`
  - Task completion toggle and refresh

### 1.4 Presentation & UI (`lib/features/tags/presentation/`)
- `widgets/tag_chip.dart`: Reusable visual chip showing tag name, optional delete/remove button, and tap handler.
- `widgets/create_tag_dialog.dart`: Dialog with text field for Admin users to create a tag.
- `widgets/tag_selector_bottom_sheet.dart`: Bottom sheet displaying all system tags with selection status, search filter, and admin create option.
- `widgets/task_tags_section.dart`: Section in `TaskDetailScreen` showing attached tag chips, "Etiket Ekle" button (for owner).
- `screens/tagged_tasks_screen.dart`: Screen with AppBar showing tag name, task count, infinite-scrolling list of `TaskCard`s.

### 1.5 Integration & DI
- Add endpoints to `ApiConstants`.
- Register `TagsRepository` in `main.dart` `MultiRepositoryProvider`.
- Embed `TaskTagsSection` in `TaskDetailScreen`.
- Display tag chips on `TaskCard`.
- Tapping a tag chip opens `TaggedTasksScreen`.

