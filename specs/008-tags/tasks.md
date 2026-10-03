# Tasks: FEAT-08 — Tags & Categorization

**Branch**: `008-tags-categorization` | **Spec**: [specs/008-tags/spec.md](spec.md) | **Plan**: [specs/008-tags/plan.md](plan.md)

---

## Phase 1: Setup & Constants

**Purpose**: Register tag endpoints in `ApiConstants`.

- [x] T001 [P] Add tag endpoints to `lib/core/constants/api_constants.dart`

---

## Phase 2: Foundational (DTOs, Data Source, Repository)

**Purpose**: Data layer models, contracts, and repository implementation for tags.

- [x] T002 [P] Create `TagResponseDto` in `lib/features/tags/data/models/tag_response_dto.dart`
- [x] T003 [P] Create `TagsCollectionResponseDto` in `lib/features/tags/data/models/tags_collection_response_dto.dart`
- [x] T004 [P] Create `CreateTagRequest` in `lib/features/tags/data/models/create_tag_request.dart`
- [x] T005 Create `TagsRemoteDataSource` in `lib/features/tags/data/datasources/tags_remote_data_source.dart`
- [x] T006 Create `TagsRepository` interface in `lib/features/tags/domain/repositories/tags_repository.dart`
- [x] T007 Implement `TagsRepositoryImpl` in `lib/features/tags/data/repositories/tags_repository_impl.dart`

---

## Phase 3: State Management (Cubits)

**Purpose**: Reactive state management for system tags, task tag attachments, and tagged task browsing.

- [x] T008 Implement `TaskTagsState` and `TaskTagsCubit` in `lib/features/tags/presentation/cubits/task_tags_cubit.dart` & `task_tags_state.dart`
- [x] T009 Implement `SystemTagsState` and `SystemTagsCubit` in `lib/features/tags/presentation/cubits/system_tags_cubit.dart` & `system_tags_state.dart`
- [x] T010 Implement `TaggedTasksState` and `TaggedTasksCubit` in `lib/features/tags/presentation/cubits/tagged_tasks_cubit.dart` & `tagged_tasks_state.dart`

---

## Phase 4: Presentation & UI

**Purpose**: Chips, modals, task tags section, and tagged tasks screen.

- [x] T011 Create `TagChip` widget in `lib/features/tags/presentation/widgets/tag_chip.dart`
- [x] T012 Create `TagSelectorBottomSheet` in `lib/features/tags/presentation/widgets/tag_selector_bottom_sheet.dart` and `CreateTagDialog` in `lib/features/tags/presentation/widgets/create_tag_dialog.dart`
- [x] T013 Create `TaskTagsSection` in `lib/features/tags/presentation/widgets/task_tags_section.dart`
- [x] T014 Create `TaggedTasksScreen` in `lib/features/tags/presentation/screens/tagged_tasks_screen.dart`

---

## Phase 5: Integration

**Purpose**: Integrate into existing screens and DI.

- [x] T015 Register `TagsRepository` in `main.dart` and `MultiRepositoryProvider`
- [x] T016 Embed `TaskTagsSection` into `TaskDetailScreen`
- [x] T017 Display tag chips on `TaskCard` with tap navigation to `TaggedTasksScreen`

---

## Phase 6: Polish, Testing & Verification

**Purpose**: Unit testing, analysis, build, and device test.

- [x] T018 Write unit tests in `test/features/tags/tags_test.dart`
- [x] T019 Run `flutter analyze` and `flutter test`
- [x] T020 Build debug APK and install on Samsung Galaxy A71 (`RZ8N20EGMJX`)
