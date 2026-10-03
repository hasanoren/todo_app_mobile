# Phase 0: Research & Technical Validation — FEAT-06 Task Management

## 1. API Contracts & Serialization Research

### 1.1 Outgoing vs. Incoming Enum Representations
- **Issue**: The backend API expects integer enums when making requests (e.g. creating/updating tasks or filtering), but serializes enums as strings in JSON responses (e.g. `"status": "Open"`, `"priority": "Medium"`).
- **Resolution**:
  - In `TodoItemEnums`:
    - `TaskPriority`: `low(0, 'Low', 'Düşük')`, `medium(1, 'Medium', 'Orta')`, `high(2, 'High', 'Yüksek')`, `urgent(3, 'Urgent', 'Acil')`.
    - Provide `fromServerString(String? val)` parsing `"Low"`, `"Medium"`, etc. case-insensitively, defaulting to `medium`.
    - Provide `toInt()` returning `0, 1, 2, 3` for query params and request bodies.
    - `TaskStatus`: `open(0, 'Open', 'Açık')`, `completed(1, 'Completed', 'Tamamlandı')`.
    - Provide `fromServerString(String? val)` parsing `"Open"`, `"Completed"`.
    - `TaskFilterType`: `all(0, 'Tümü')`, `onlyMine(1, 'Bana Ait')`, `sharedWithMe(2, 'Benimle Paylaşılan')`, `sharedByMe(3, 'Paylaştıklarım')`.
    - `TaskSortBy`: `createdAt('createdAt', 'Oluşturulma')`, `dueDate('dueDate', 'Bitiş Tarihi')`, `title('title', 'Başlık')`, `priority('priority', 'Öncelik')`.
    - `SortOrder`: `desc('desc', 'Azalan')`, `asc('asc', 'Artan')`.

### 1.2 Pagination Strategy
- **Backend Model**:
  ```json
  {
    "items": [...],
    "page": 1,
    "pageSize": 20,
    "totalCount": 45,
    "totalPages": 3,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
  ```
- **Flutter Implementation**:
  - `TasksCubit` maintains `page`, `pageSize`, `hasNextPage`, `isLoadingMore`, `items`.
  - Initial load / filter change resets `page = 1`, fetches first page.
  - Scroll controller on `TasksScreen` triggers `loadNextPage()` when user scrolls within 200px of max extent.
  - Pull-to-refresh triggers `refreshTasks()`, resetting to page 1 without wiping existing list until response arrives.

### 1.3 List Integration with FEAT-05
- `todoListId` can be passed as an optional filter to `TasksScreen` (e.g. when user clicks on a list card in `TodoListsScreen`).
- In `TaskFormModal`, user can select from their available lists using `TodoListsRepository.getTodoLists()`.

### 1.4 Soft Delete & Confirmation
- `DELETE /api/TodoItems/{id}` moves item to trash (`204 No Content`).
- UI presents a modal confirmation dialog before executing delete.
- Once deleted, item is removed from Cubit list state and a SnackBar is displayed.

