# Tasks: FEAT-05 — Todo Lists (Görev Listeleri)

**Branch**: `005-todo-lists` | **Spec**: [specs/005-todo-lists/spec.md](spec.md) | **Plan**: [specs/005-todo-lists/plan.md](plan.md)

---

## Phase 1: Setup, Constants & Utilities

**Purpose**: Register endpoints, routes, and color conversion utilities.

- [x] T001 [P] Add `todoLists = '/api/TodoLists'` to `lib/core/constants/api_constants.dart`
- [x] T002 [P] Add `todoLists = '/todo-lists'` to `lib/core/router/route_names.dart`
- [x] T003 [P] Create `ColorUtils` with hex converter and preset palette in `lib/core/utils/color_utils.dart`

---

## Phase 2: Foundational (Data Layer & Contracts)

**Purpose**: Create DTOs, data source methods, and repository contracts for TodoLists.

- [x] T004 [P] Create `TodoListResponseDto` in `lib/features/todo_lists/data/models/todo_list_response_dto.dart`
- [x] T005 [P] Create `CreateTodoListRequest` in `lib/features/todo_lists/data/models/create_todo_list_request.dart`
- [x] T006 [P] Create `UpdateTodoListRequest` in `lib/features/todo_lists/data/models/update_todo_list_request.dart`
- [x] T007 [P] Create `TodoListsCollectionResponseDto` in `lib/features/todo_lists/data/models/todo_lists_collection_response_dto.dart`
- [x] T008 Create `TodoListsRemoteDataSource` and implementation in `lib/features/todo_lists/data/datasources/todo_lists_remote_data_source.dart`
- [x] T009 Create `TodoListsRepository` interface in `lib/features/todo_lists/domain/repositories/todo_lists_repository.dart`
- [x] T010 Implement `TodoListsRepositoryImpl` in `lib/features/todo_lists/data/repositories/todo_lists_repository_impl.dart`

---

## Phase 3: State Management (Cubits)

**Purpose**: Reactive state management for list browsing and form operations.

- [x] T011 Define `TodoListsState` and `TodoListsCubit` in `lib/features/todo_lists/presentation/cubits/todo_lists_cubit.dart` & `todo_lists_state.dart`
- [x] T012 Define `TodoListFormState` and `TodoListFormCubit` in `lib/features/todo_lists/presentation/cubits/todo_list_form_cubit.dart` & `todo_list_form_state.dart`

---

## Phase 4: User Story 1 - Görev Listelerini Görüntüleme (Priority: P1)

**Goal**: Display lists with color indicators, pull-to-refresh, and empty state.

- [x] T013 [US1] Create `TodoListCard` widget in `lib/features/todo_lists/presentation/widgets/todo_list_card.dart`
- [x] T014 [US1] Create `TodoListsScreen` with empty state, error handling, and pull-to-refresh in `lib/features/todo_lists/presentation/screens/todo_lists_screen.dart`
- [x] T015 [US1] Register `/todo-lists` route in `lib/core/router/app_router.dart` and add navigation icon to `HomeScreen`

---

## Phase 5: User Story 2 - Yeni Görev Listesi Oluşturma (Priority: P1)

**Goal**: Allow user to create a new list with name and color selection.

- [x] T016 [US2] Create `ColorPickerGrid` widget in `lib/features/todo_lists/presentation/widgets/color_picker_grid.dart`
- [x] T017 [US2] Create `TodoListFormModal` bottom sheet for creating/editing lists in `lib/features/todo_lists/presentation/widgets/todo_list_form_modal.dart`
- [x] T018 [US2] Connect "+" FAB button on `TodoListsScreen` to open creation modal and refresh lists on success

---

## Phase 6: User Story 3 & 4 - Görev Listesini Düzenleme ve Silme (Priority: P2)

**Goal**: Allow editing existing list details and deleting lists with confirmation.

- [x] T019 [US3] Connect "Düzenle" option on `TodoListCard` to open `TodoListFormModal` with existing values and trigger update
- [x] T020 [US4] Create deletion confirmation dialog and trigger `TodoListsCubit.deleteList`
- [x] T021 [US4] Show feedback SnackBar upon successful list update or deletion

---

## Phase 7: Polish & Verification

**Purpose**: Test coverage, lint verification, and physical device test.

- [x] T022 Write unit tests for `TodoListsCubit` and `TodoListFormCubit` in `test/features/todo_lists/todo_lists_test.dart`
- [x] T023 Run `flutter analyze` to ensure 0 static analysis errors or warnings
- [x] T024 Run `flutter test` to ensure all tests pass
- [x] T025 Build and verify on Samsung Galaxy A71 device per `specs/005-todo-lists/quickstart.md`

