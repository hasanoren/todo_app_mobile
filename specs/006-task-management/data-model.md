# Data Model: FEAT-06 Task Management

## Entities & Data Transfer Objects

### 1. `TodoItemResponseDto` (`TodoItemResponse`)
Represents an individual task item returned from the API.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID of the task |
| `title` | `String` | Title of the task (max 200 chars) |
| `description` | `String?` | Optional detailed description |
| `dueDate` | `DateTime?` | Optional due date in UTC |
| `status` | `String` | String enum ("Open", "Completed") |
| `priority` | `String` | String enum ("Low", "Medium", "High", "Urgent") |
| `todoListId` | `String?` | Optional UUID of associated TodoList |
| `ownerId` | `String` | UUID of the user who owns the task |
| `isOwner` | `bool` | Whether the authenticated user owns this task |
| `completedByUserId` | `String?` | UUID of the user who marked it complete |
| `completedAt` | `DateTime?` | Timestamp when completed |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime?` | Last update timestamp |
| `isDeleted` | `bool` | Soft-delete status |
| `deletedAt` | `DateTime?` | Deletion timestamp |
| `subTasks` | `List<SubTaskItemDto>` | Embedded subtasks |
| `tags` | `List<TagItemDto>` | Embedded tags |
| `sharedWith` | `List<SharedUserItemDto>` | Embedded shared users |

### 2. `PaginatedResponseDto<T>`
Generic pagination container matching server schema:
```dart
class PaginatedResponseDto<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
}
```

### 3. `CreateTodoItemRequest`
DTO sent to `POST /api/TodoItems`:
```dart
class CreateTodoItemRequest {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority; // 0=Low, 1=Medium, 2=High, 3=Urgent
  final String? todoListId;
}
```

### 4. `UpdateTodoItemRequest`
DTO sent to `PUT /api/TodoItems/{id}`:
```dart
class UpdateTodoItemRequest {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  final String? todoListId;
}
```

### 5. `TodoItemFilterDto`
Query parameters model for `GET /api/TodoItems`:
```dart
class TodoItemFilterDto {
  final int filterType; // 0=All, 1=OnlyMine, 2=SharedWithMe, 3=SharedByMe
  final String? search;
  final int? status; // 0=Open, 1=Completed
  final int? priority; // 0..3
  final String? todoListId;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final String sortBy; // "createdAt", "dueDate", "title", "priority"
  final String sortOrder; // "desc", "asc"
  final int page;
  final int pageSize;
}
```
