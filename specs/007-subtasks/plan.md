# Implementation Plan: FEAT-07 Subtasks (Checklist)

**Branch**: `007-subtasks` | **Date**: 2026-10-03 | **Spec**: [specs/007-subtasks/spec.md](spec.md)

**Input**: Feature specification from `specs/007-subtasks/spec.md`

## Summary

Implement subtask checklist management within parent todo items, enabling users to add subtasks, toggle completion status, view visual completion progress, and delete subtasks (owner only), integrated smoothly into `TaskDetailScreen`.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `dio`, `equatable`  
**Target Platform**: Android (Samsung Galaxy A71) & iOS  
**Project Type**: Mobile Application  
**Constraints**: Follow Constitution (Feature isolation under `lib/features/subtasks/`, Dio client, RFC 7807 error handling, 0 analyzer issues)

## Constitution Check

- [x] **Principle I: API-First Consumer**: Strictly complies with `docs/spec.md` subtasks endpoints.
- [x] **Principle II: Feature-Isolated Architecture**: Subtasks module created under `lib/features/subtasks/`.
- [x] **Principle III: Bloc-Driven State Management**: `SubtasksCubit` and `SubtasksState`.
- [x] **Principle IV: Dio-Powered Network Layer**: Central `DioClient`.
- [x] **Principle VII: Simplicity & YAGNI**: Direct, responsive checklist UX.

## Project Structure

### Documentation
```text
specs/007-subtasks/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── subtasks-endpoints.json
└── tasks.md
```

### Source Code Layout
```text
lib/
├── core/
│   └── constants/
│       └── api_constants.dart           # Register subtasks endpoint templates
└── features/
    └── subtasks/
        ├── data/
        │   ├── datasources/
        │   │   └── subtasks_remote_data_source.dart
        │   ├── models/
        │   │   ├── create_subtask_request.dart
        │   │   ├── subtask_response_dto.dart
        │   │   └── subtasks_collection_response_dto.dart
        │   └── repositories/
        │       └── subtasks_repository_impl.dart
        ├── domain/
        │   └── repositories/
        │       └── subtasks_repository.dart
        └── presentation/
            ├── cubits/
            │   ├── subtasks_cubit.dart
            │   └── subtasks_state.dart
            └── widgets/
                ├── subtask_item_tile.dart
                └── subtasks_section.dart
```

