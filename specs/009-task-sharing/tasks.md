# Tasks: FEAT-09 — Task Sharing & Member Access

## Task Overview

- [ ] Task 1: API Constants & Data Layer Models
  - Add task sharing endpoints to `lib/core/constants/api_constants.dart`
  - Create `ShareTaskRequest` in `lib/features/task_shares/data/models/`
  - Create `ShareTaskResponseDto` in `lib/features/task_shares/data/models/`
  - Create `SharesCollectionResponseDto` in `lib/features/task_shares/data/models/`

- [ ] Task 2: Remote Data Source & Repository
  - Create `TaskSharesRemoteDataSource` & implementation in `lib/features/task_shares/data/datasources/`
  - Create `TaskSharesRepository` interface in `lib/features/task_shares/domain/repositories/`
  - Create `TaskSharesRepositoryImpl` in `lib/features/task_shares/data/repositories/`

- [ ] Task 3: State Management (TaskSharesCubit)
  - Create `TaskSharesCubit` and `TaskSharesState` in `lib/features/task_shares/presentation/cubits/`

- [ ] Task 4: UI Widgets
  - Create `ShareTaskDialog` in `lib/features/task_shares/presentation/widgets/`
  - Create `TaskSharesSection` in `lib/features/task_shares/presentation/widgets/`
  - Update `TaskCard` to show collaborator counts and "Paylaşıldı" indicator
  - Update `TaskDetailScreen` to embed `TaskSharesSection`

- [ ] Task 5: DI & App Wiring
  - Register `TaskSharesRepository` in `main.dart` `MultiRepositoryProvider`

- [ ] Task 6: Unit Testing & Verification
  - Create unit tests in `test/features/task_shares/task_shares_test.dart`
  - Verify zero analyzer warnings with `dart analyze lib test`
  - Run all tests with `flutter test`
  - Build debug APK and install on Samsung Galaxy A71

