# Implementation Plan: FEAT-06 Task Management (CRUD, Search, Filter & Pagination)

**Branch**: `006-task-management` | **Date**: 2026-10-03 | **Spec**: [specs/006-task-management/spec.md](spec.md)

**Input**: Feature specification from `specs/006-task-management/spec.md`

## Summary

Implement the core task management engine for TodoApp Mobile, allowing authenticated users to browse paginated tasks, search, filter by status/priority/list/dates, sort, create new tasks, view full details, edit task fields, toggle completion (Open ↔ Completed), and soft-delete tasks with confirmation.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `dio`, `go_router`, `equatable`, `intl`  
**Storage**: SecureStorage (tokens)  
**Testing**: `flutter test` (unit and widget tests)  
**Target Platform**: Android (primary: Samsung Galaxy A71, API 33) & iOS  
**Project Type**: Mobile Application  
**Performance Goals**: Smooth 60 FPS scrolling, sub-second search debounce (400ms), instant optimistic or rapid UI toggle feedback  
**Constraints**: Follow Constitution (Clean Architecture, Feature-Isolated, Bloc/Cubit, Dio interceptors, zero linter warnings)

## Constitution Check

- [x] **Principle I: API-First Consumer**: Strictly complies with `docs/spec.md` for `/api/TodoItems`.
- [x] **Principle II: Feature-Isolated Architecture**: Implemented under `lib/features/tasks/` (`data/`, `domain/`, `presentation/`).
- [x] **Principle III: Bloc-Driven State Management**: Cubits for tasks browsing/pagination (`TasksCubit`), task form (`TaskFormCubit`), and task detail (`TaskDetailCubit`).
- [x] **Principle IV: Dio-Powered Network Layer**: Uses central `DioClient` with JWT interceptor and RFC 7807 error parsing.
- [x] **Principle V: Secure Token Lifecycle**: Protected endpoints automatically use stored bearer tokens.
- [x] **Principle VII: Simplicity & YAGNI**: No unneeded local database cache or speculative endpoints.

## Project Structure

### Documentation
```text
specs/006-task-management/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── tasks-endpoints.json
└── tasks.md
```

### Source Code Layout
```text
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart             # Register /api/TodoItems
│   ├── router/
│   │   ├── app_router.dart                # Register /tasks and /tasks/:id
│   │   └── route_names.dart               # tasks, taskDetail
├── features/
│   └── tasks/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── todo_items_remote_data_source.dart
│       │   ├── models/
│       │   │   ├── todo_item_response_dto.dart
│       │   │   ├── paginated_todo_items_response_dto.dart
│       │   │   ├── create_todo_item_request.dart
│       │   │   ├── update_todo_item_request.dart
│       │   │   └── todo_item_filter_dto.dart
│       │   └── repositories/
│       │       └── todo_items_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── todo_item_enums.dart
│       │   └── repositories/
│       │       └── todo_items_repository.dart
│       └── presentation/
│           ├── cubits/
│           │   ├── tasks_cubit.dart
│           │   ├── tasks_state.dart
│           │   ├── task_form_cubit.dart
│           │   ├── task_form_state.dart
│           │   ├── task_detail_cubit.dart
│           │   └── task_detail_state.dart
│           ├── screens/
│           │   ├── tasks_screen.dart
│           │   └── task_detail_screen.dart
│           └── widgets/
│               ├── task_card.dart
│               ├── task_form_modal.dart
│               ├── task_filter_bottom_sheet.dart
│               └── priority_badge.dart
test/
└── features/
    └── tasks/
        └── tasks_test.dart
```
