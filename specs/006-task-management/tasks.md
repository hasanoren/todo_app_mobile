# Tasks: FEAT-06 — Task Management (CRUD, Search, Filter & Pagination)

**Branch**: `006-task-management` | **Spec**: [specs/006-task-management/spec.md](spec.md) | **Plan**: [specs/006-task-management/plan.md](plan.md)

---

## Phase 1: Setup & Constants

**Purpose**: Register API endpoints and routes for tasks.

- [x] T001 [P] Add `todoItems = '/api/TodoItems'` to `lib/core/constants/api_constants.dart`
- [x] T002 [P] Add `tasks = '/tasks'` and `taskDetail = '/tasks/:id'` to `lib/core/router/route_names.dart`

---

## Phase 2: Foundational (Entities, DTOs & Data Layer)

**Purpose**: Domain models, DTOs, data sources, and repository contracts for tasks.

- [x] T003 [P] Create domain enums in `lib/features/tasks/domain/entities/todo_item_enums.dart` (`TaskPriority`, `TaskStatus`, `TaskFilterType`, `TaskSortBy`, `SortOrder`)
- [x] T004 [P] Create `PaginatedResponseDto<T>` in `lib/features/tasks/data/models/paginated_todo_items_response_dto.dart`
- [x] T005 [P] Create `TodoItemResponseDto`, `SubTaskItemDto`, `TagItemDto`, `SharedUserItemDto` in `lib/features/tasks/data/models/todo_item_response_dto.dart`
- [x] T006 [P] Create `CreateTodoItemRequest` in `lib/features/tasks/data/models/create_todo_item_request.dart`
- [x] T007 [P] Create `UpdateTodoItemRequest` in `lib/features/tasks/data/models/update_todo_item_request.dart`
- [x] T008 [P] Create `TodoItemFilterDto` in `lib/features/tasks/data/models/todo_item_filter_dto.dart`
- [x] T009 Create `TodoItemsRemoteDataSource` interface and implementation in `lib/features/tasks/data/datasources/todo_items_remote_data_source.dart`
- [x] T010 Create `TodoItemsRepository` interface in `lib/features/tasks/domain/repositories/todo_items_repository.dart`
- [x] T011 Implement `TodoItemsRepositoryImpl` in `lib/features/tasks/data/repositories/todo_items_repository_impl.dart`

---

## Phase 3: State Management (Cubits)

**Purpose**: Reactive state management for browsing, filtering, task form, and details.

- [x] T012 Implement `TasksState` and `TasksCubit` in `lib/features/tasks/presentation/cubits/tasks_cubit.dart` & `tasks_state.dart`
- [x] T013 Implement `TaskFormState` and `TaskFormCubit` in `lib/features/tasks/presentation/cubits/task_form_cubit.dart` & `task_form_state.dart`
- [x] T014 Implement `TaskDetailState` and `TaskDetailCubit` in `lib/features/tasks/presentation/cubits/task_detail_cubit.dart` & `task_detail_state.dart`

---

## Phase 4: User Story 1 - Paginated Task Browsing & Quick Toggle (Priority: P1)

**Goal**: Display tasks with infinite scrolling, pull-to-refresh, priority indicators, and quick completion toggle.

- [x] T015 [US1] Create `PriorityBadge` widget in `lib/features/tasks/presentation/widgets/priority_badge.dart`
- [x] T016 [US1] Create `TaskCard` widget in `lib/features/tasks/presentation/widgets/task_card.dart`
- [x] T017 [US1] Create `TasksScreen` with infinite scroll, empty state, and pull-to-refresh in `lib/features/tasks/presentation/screens/tasks_screen.dart`
- [x] T018 [US1] Connect `PATCH /api/TodoItems/{id}/complete` quick completion toggle on checkbox tap

---

## Phase 5: User Story 2 - Task Creation (Priority: P1)

**Goal**: Allow creating a task with title, description, priority, due date, and list selector.

- [x] T019 [US2] Create `TaskFormModal` bottom sheet in `lib/features/tasks/presentation/widgets/task_form_modal.dart`
- [x] T020 [US2] Connect FAB on `TasksScreen` to open `TaskFormModal` and refresh list on task creation

---

## Phase 6: User Story 3 - Search, Filter & Sort (Priority: P2)

**Goal**: Add debounced keyword search and bottom sheet filtering by status, priority, list, and sort criteria.

- [x] T021 [US3] Create `TaskFilterBottomSheet` in `lib/features/tasks/presentation/widgets/task_filter_bottom_sheet.dart`
- [x] T022 [US3] Integrate search bar and filter controls into `TasksScreen`

---

## Phase 7: User Story 4 & 5 - Task Detail, Edit & Soft Delete (Priority: P2/P3)

**Goal**: Full task detail screen with edit and soft-delete capabilities.

- [x] T023 [US4] Create `TaskDetailScreen` in `lib/features/tasks/presentation/screens/task_detail_screen.dart`
- [x] T024 [US4] Connect "Düzenle" action to open `TaskFormModal` in edit mode (`PUT /api/TodoItems/{id}`)
- [x] T025 [US5] Implement soft delete confirmation dialog and trigger `DELETE /api/TodoItems/{id}`

---

## Phase 8: Routing & Cross-Feature Integration

**Purpose**: Wire tasks into AppRouter, HomeScreen, and TodoLists navigation.

- [x] T026 Wire `/tasks` and `/tasks/:id` into `AppRouter`, add "Tüm Görevler" to `HomeScreen`, and link `TodoListCard` to `/tasks?todoListId=...`
- [x] T027 Register dependencies in `main.dart`

---

## Phase 9: Polish, Testing & Verification

**Purpose**: Automated tests, lint check, build, and device verification.

- [x] T028 Write unit and widget tests in `test/features/tasks/tasks_test.dart`
- [x] T029 Run `flutter analyze` and `flutter test`
- [x] T030 Build debug APK and install on Samsung Galaxy A71 (`RZ8N20EGMJX`)

