# Implementation Plan: FEAT-12 — Task Activity History

## Architecture & File Structure

```text
lib/
├── features/
│   └── task_activities/
│       ├── data/
│       │   ├── models/
│       │   │   └── todo_item_activity_response_dto.dart
│       │   ├── datasources/
│       │   │   ├── task_activities_remote_data_source.dart
│       │   │   └── task_activities_remote_data_source_impl.dart
│       │   └── repositories/
│       │       └── task_activities_repository_impl.dart
│       ├── domain/
│       │   └── repositories/
│       │       └── task_activities_repository.dart
│       └── presentation/
│           ├── cubits/
│           │   ├── task_activities_cubit.dart
│           │   └── task_activities_state.dart
│           └── widgets/
│               ├── task_activity_item_tile.dart
│               └── task_activities_section.dart
```

## Integration Points
1. `lib/main.dart`:
   - `TaskActivitiesRemoteDataSourceImpl` & `TaskActivitiesRepositoryImpl` initialization
   - `RepositoryProvider<TaskActivitiesRepository>` provision in `MultiRepositoryProvider`
2. `lib/features/tasks/presentation/screens/task_detail_screen.dart`:
   - Embed `TaskActivitiesSection(taskId: task.id)` inside the detail view scrollable column.

## Testing Strategy
- Model parsing tests: JSON serialization and null handling.
- Cubit tests: Loading, success, error, and `isClosed` safety.
- Repository tests: HTTP call delegation and error wrapping.
