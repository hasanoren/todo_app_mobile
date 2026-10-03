# Tasks: FEAT-07 — Subtasks (Checklist)

**Branch**: `007-subtasks` | **Spec**: [specs/007-subtasks/spec.md](spec.md) | **Plan**: [specs/007-subtasks/plan.md](plan.md)

---

## Phase 1: Setup & Constants

**Purpose**: Register subtasks endpoints.

- [x] T001 [P] Add subtasks endpoints to `lib/core/constants/api_constants.dart`

---

## Phase 2: Foundational (DTOs, Data Source, Repository)

**Purpose**: Data layer models, contracts, and repository implementation for subtasks.

- [x] T002 [P] Create `SubtaskResponseDto` in `lib/features/subtasks/data/models/subtask_response_dto.dart`
- [x] T003 [P] Create `SubtasksCollectionResponseDto` in `lib/features/subtasks/data/models/subtasks_collection_response_dto.dart`
- [x] T004 [P] Create `CreateSubtaskRequest` in `lib/features/subtasks/data/models/create_subtask_request.dart`
- [x] T005 Create `SubtasksRemoteDataSource` interface and implementation in `lib/features/subtasks/data/datasources/subtasks_remote_data_source.dart`
- [x] T006 Create `SubtasksRepository` interface in `lib/features/subtasks/domain/repositories/subtasks_repository.dart`
- [x] T007 Implement `SubtasksRepositoryImpl` in `lib/features/subtasks/data/repositories/subtasks_repository_impl.dart`

---

## Phase 3: State Management (Cubit)

**Purpose**: Reactive state management for subtask list, adding, toggling, and deleting.

- [x] T008 Implement `SubtasksState` and `SubtasksCubit` in `lib/features/subtasks/presentation/cubits/subtasks_cubit.dart` & `subtasks_state.dart`

---

## Phase 4: Presentation & UI

**Purpose**: Checklist item tile and full subtasks section widget with progress indicator.

- [x] T009 Create `SubtaskItemTile` in `lib/features/subtasks/presentation/widgets/subtask_item_tile.dart`
- [x] T010 Create `SubtasksSection` in `lib/features/subtasks/presentation/widgets/subtasks_section.dart`

---

## Phase 5: Integration

**Purpose**: Integrate subtasks section into task details and register DI.

- [x] T011 Embed `SubtasksSection` into `TaskDetailScreen`
- [x] T012 Register `SubtasksRepository` in `main.dart` and `MultiRepositoryProvider`

---

## Phase 6: Polish, Testing & Verification

**Purpose**: Unit testing, analysis, build, and device test.

- [x] T013 Write unit tests in `test/features/subtasks/subtasks_test.dart`
- [x] T014 Run `flutter analyze` and `flutter test`
- [ ] T015 Build debug APK and install on Samsung Galaxy A71 (`RZ8N20EGMJX`)
