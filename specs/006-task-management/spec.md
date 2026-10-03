# Feature Specification: FEAT-06 — Task Management (CRUD, Search, Filter & Pagination)

**Feature Branch**: `006-task-management`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User request: "tamam çalışıyor şimdi diğer feature'a geçelim" -> FEAT-06 Task Management (CRUD, Search, Filter & Pagination)

---

## Overview

FEAT-06 is the core engine of the application. It enables users to create, browse, paginate, search, filter, sort, view detailed information, edit, toggle completion, and soft-delete todo items.

---

## User Scenarios & Testing

### User Story 1 - Paginated Task Browsing & Quick Toggle (Priority: P1)

As an authenticated user, I want to see a paginated list of my tasks with clear status and priority indicators, and quickly toggle a task between Open and Completed, so that I can stay on top of my to-dos efficiently.

**Why this priority**:
Viewing and completing tasks is the fundamental core interaction of any Todo application. Without this, no task workflow can be completed.

**Independent Test**:
Log in, open the main tasks feed, see existing tasks loaded with pagination, tap a completion checkbox, and verify the task status changes immediately with server sync.

**Acceptance Scenarios**:
1. **Given** an authenticated user with existing tasks, **When** opening the tasks screen, **Then** the first page of tasks is loaded (`pageSize=20`) showing title, priority badge, due date, and completion checkbox.
2. **Given** the user is viewing the task list, **When** scrolling to the bottom of the page, **Then** the next page of items is automatically fetched and appended if `hasNextPage` is true.
3. **Given** a task with `status: "Open"`, **When** the user taps the checkbox, **Then** a `PATCH /api/TodoItems/{id}/complete` request is sent, the task is marked as `Completed`, and visual strike-through / checked state is rendered.
4. **Given** a task list, **When** the user performs a pull-to-down gesture, **Then** page 1 is reloaded and the list is refreshed.

---

### User Story 2 - Task Creation (Priority: P1)

As an authenticated user, I want to create a new task with a title, optional description, due date, priority, and list assignment, so that I can capture items to do.

**Why this priority**:
Creating tasks is essential to populating the system with work items.

**Independent Test**:
Tap the "+" Floating Action Button, enter a title, choose a priority and optional due date/list, submit, and observe the new task appear at the top of the task list.

**Acceptance Scenarios**:
1. **Given** the task creation form, **When** the user enters a valid title (1-200 characters), selects priority (default: Medium), selects an optional due date and list, and taps "Oluştur", **Then** `POST /api/TodoItems` is invoked with integer priority enum and formatted ISO dates, and the task list is refreshed.
2. **Given** the task creation form, **When** the title is empty or whitespace, **Then** a client-side validation error is shown ("Başlık boş bırakılamaz") and no API call is made.

---

### User Story 3 - Search, Filter & Sort (Priority: P2)

As a user with many tasks, I want to search tasks by keywords and filter by filter type (All, OnlyMine, SharedWithMe, SharedByMe), status, priority, list, or date range, and sort by different criteria, so that I can quickly find the exact tasks I need.

**Why this priority**:
Enables users to manage larger task collections effectively without getting overwhelmed.

**Independent Test**:
Enter search terms in the search bar or pick a filter chip (e.g. Priority: High or Status: Open) and observe that the task query parameters update and fetch matching items.

**Acceptance Scenarios**:
1. **Given** the task screen, **When** the user types "Report" in the search field, **Then** after a 400ms debounce, `GET /api/TodoItems` is called with `search=Report` resetting to page 1.
2. **Given** the filter options, **When** the user selects `status=0` (Open) or `priority=2` (High), **Then** only open / high-priority tasks are fetched and displayed.
3. **Given** a list is passed (e.g. from FEAT-05 `TodoListCard`), **When** navigating to the tasks screen with `todoListId`, **Then** the list is pre-filtered by that list ID and displays the list title in the header.
4. **Given** sort options, **When** the user changes sort to `dueDate asc`, **Then** `sortBy=dueDate&sortOrder=asc` is applied.

---

### User Story 4 - Task Detail & Edit (Priority: P2)

As an owner of a task, I want to view the full details of a task and edit its properties (title, description, priority, due date, list assignment), so that I can update task requirements over time.

**Why this priority**:
Tasks evolve over their lifecycle and need updates to their descriptions and deadlines.

**Independent Test**:
Tap on a task card, view `GET /api/TodoItems/{id}` details, tap "Düzenle", modify the description or priority, save, and verify updated information is shown.

**Acceptance Scenarios**:
1. **Given** a task card, **When** tapped, **Then** navigate to `TaskDetailScreen` fetching `GET /api/TodoItems/{id}` with embedded collections (`subTasks`, `tags`, `sharedWith`).
2. **Given** the detail screen for a task owned by the user (`isOwner: true`), **When** tapping edit, **Then** open the edit modal prefilled with current values; upon submit `PUT /api/TodoItems/{id}` is executed.
3. **Given** a task not owned by the user (`isOwner: false`), **When** viewing details, **Then** edit and delete actions are disabled or hidden.

---

### User Story 5 - Soft Delete to Trash (Priority: P3)

As a task owner, I want to delete a task so that it is moved to the trash without losing it permanently immediately.

**Why this priority**:
Prevents accidental data loss and allows cleaning up obsolete tasks.

**Independent Test**:
Select "Sil" from a task card menu or detail action, confirm in the dialog, verify `DELETE /api/TodoItems/{id}` is called, and see the task disappear from the active task list.

**Acceptance Scenarios**:
1. **Given** a task card or detail screen, **When** the user selects "Sil", **Then** a confirmation dialog is presented ("Bu görevi silmek istediğinize emin misiniz?").
2. **Given** confirmed deletion, **When** `DELETE /api/TodoItems/{id}` succeeds (`204 No Content`), **Then** a success SnackBar is shown and the task is removed from the active list.

---

## Edge Cases

- **Network Offline / Timeout**: Show an error banner or retry button with clear message; preserve current filters.
- **Empty List Result**: Show an informative empty state illustration/icon ("Henüz görev bulunamadı" / "Aramanızla eşleşen görev yok").
- **Overdue Tasks**: Tasks with `dueDate < DateTime.now()` and `status: Open` should show overdue indicator (red due date text).
- **Pagination Boundary**: Disable infinite scroll trigger when `hasNextPage: false`.
- **String Enums from Server vs Integer Enums to Server**:
  - Outgoing create/update: `priority` (0=Low, 1=Medium, 2=High, 3=Urgent), `status` (0=Open, 1=Completed), `filterType` (0=All, 1=OnlyMine, 2=SharedWithMe, 3=SharedByMe).
  - Incoming response: `priority` is string ("Low", "Medium", "High", "Urgent"), `status` is string ("Open", "Completed").

---

## Requirements

### Functional Requirements

- **FR-001**: System MUST fetch paginated tasks from `GET /api/TodoItems` supporting query params: `filterType`, `search`, `status`, `priority`, `todoListId`, `dueDateFrom`, `dueDateTo`, `sortBy`, `sortOrder`, `page`, `pageSize`.
- **FR-002**: System MUST parse `PaginatedResponse<TodoItemResponse>` with `items`, `page`, `pageSize`, `totalCount`, `totalPages`, `hasNextPage`, `hasPreviousPage`.
- **FR-003**: System MUST support creating tasks via `POST /api/TodoItems` with `title` (required, 1-200 chars), optional `description`, optional `dueDate` (UTC), optional `priority` (default: 1 Medium), optional `todoListId`.
- **FR-004**: System MUST support fetching full task details via `GET /api/TodoItems/{id}`.
- **FR-005**: System MUST support full task update via `PUT /api/TodoItems/{id}` for task owners.
- **FR-006**: System MUST support toggling task completion via `PATCH /api/TodoItems/{id}/complete`.
- **FR-007**: System MUST support soft-deleting tasks via `DELETE /api/TodoItems/{id}`.
- **FR-008**: System MUST support debounced search and filtering by status, priority, filterType, and list assignment.
- **FR-009**: System MUST support navigation between `HomeScreen`, `TodoListsScreen`, `TasksScreen`, and `TaskDetailScreen`.

---

## Key Entities

- **TodoItem**: Core entity representing a task: `id`, `title`, `description`, `dueDate`, `status`, `priority`, `todoListId`, `ownerId`, `isOwner`, `createdAt`, `updatedAt`, `isDeleted`, `subTasks`, `tags`, `sharedWith`.
- **TodoItemFilter**: Model holding active query filter state: `filterType`, `search`, `status`, `priority`, `todoListId`, `dueDateFrom`, `dueDateTo`, `sortBy`, `sortOrder`, `page`, `pageSize`.
- **PaginatedResponse<T>**: Generic pagination wrapper model.

---

## Success Criteria

- **SC-001**: User can browse tasks with infinite scrolling and pull-to-refresh smoothly.
- **SC-002**: User can create a task in under 10 seconds with validation feedback.
- **SC-003**: Tapping complete immediately provides responsive UI feedback and syncs with backend.
- **SC-004**: Search returns debounced matching tasks without UI stutter.
- **SC-005**: Zero flutter analyzer errors and 100% passing tests.

