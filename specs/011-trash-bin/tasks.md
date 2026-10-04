# Tasks: FEAT-11 — Çöp Kutusu & Geri Yükleme (Trash & Recycle Bin)

**Branch**: `011-trash-bin` | **Spec**: [specs/011-trash-bin/spec.md](spec.md) | **Plan**: [specs/011-trash-bin/plan.md](plan.md)

---

## Phase 1: Setup & API Constants
- [x] T001 Add `todoItemsTrash`, `todoItemRestore`, and `todoItemPermanent` to `lib/core/constants/api_constants.dart`
- [x] T002 Add `trash = '/trash'` to `lib/core/router/route_names.dart`

---

## Phase 2: Data & Domain Layer
- [x] T003 Add trash methods to `TodoItemsRemoteDataSource` (`getTrashItems`, `restoreTodoItem`, `permanentDeleteTodoItem`)
- [x] T004 Add trash methods to `TodoItemsRepository` and implement in `TodoItemsRepositoryImpl`

---

## Phase 3: State Management (Cubits)
- [x] T005 Create `TrashState` and `TrashCubit` in `lib/features/tasks/presentation/cubits/trash_cubit.dart` and `trash_state.dart`

---

## Phase 4: Presentation & UI
- [x] T006 Create `TrashTaskCard` in `lib/features/tasks/presentation/widgets/trash_task_card.dart`
- [x] T007 Create `TrashScreen` in `lib/features/tasks/presentation/screens/trash_screen.dart` with pull-to-refresh, infinite scroll, and confirmation dialog

---

## Phase 5: Navigation & App Integration
- [x] T008 Register `/trash` route in `lib/core/router/app_router.dart`
- [x] T009 Add "Çöp Kutusu" action button in `TasksScreen` and `HomeScreen`

---

## Phase 6: Testing & Quality Gates
- [x] T010 Write unit tests in `test/features/tasks/trash_test.dart`
- [x] T011 Run `dart analyze lib test` (0 issues)
- [x] T012 Run `flutter test` (all tests pass)
- [x] T013 Build debug APK and install on Samsung Galaxy A71 (`RZ8N20EGMJX`)
