# Tasks: FEAT-12 — Task Activity History

## 1. Data Layer
- [x] T001: Create `TodoItemActivityResponseDto` in `lib/features/task_activities/data/models/todo_item_activity_response_dto.dart`
- [x] T002: Create `TaskActivitiesRemoteDataSource` in `lib/features/task_activities/data/datasources/task_activities_remote_data_source.dart`
- [x] T003: Create `TaskActivitiesRemoteDataSourceImpl` with Dio handling
- [x] T004: Create domain `TaskActivitiesRepository` in `lib/features/task_activities/domain/repositories/task_activities_repository.dart`
- [x] T005: Create `TaskActivitiesRepositoryImpl` in `lib/features/task_activities/data/repositories/task_activities_repository_impl.dart`

## 2. Presentation Layer
- [x] T006: Create `TaskActivitiesState` and `TaskActivitiesCubit` in `lib/features/task_activities/presentation/cubits/`
- [x] T007: Create `TaskActivityItemTile` with custom action icons, timestamps, and details
- [x] T008: Create `TaskActivitiesSection` expandable/timeline card widget for `TaskDetailScreen`
- [x] T009: Embed `TaskActivitiesSection` into `lib/features/tasks/presentation/screens/task_detail_screen.dart`

## 3. Dependency Injection & Routing
- [x] T010: Register `TaskActivitiesRepository` in `lib/main.dart`

## 4. Testing & Verification
- [x] T011: Create unit tests in `test/features/task_activities/task_activities_test.dart`
- [x] T012: Verify with `dart analyze lib test` and `flutter test`
