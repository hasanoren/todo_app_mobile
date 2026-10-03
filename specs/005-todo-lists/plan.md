# Implementation Plan: FEAT-05 — Todo Lists (Görev Listeleri)

**Branch**: `005-todo-lists` | **Spec**: [specs/005-todo-lists/spec.md](spec.md)

---

## 1. Technical Context

- **Endpoints**:
  - `POST /api/TodoLists` (Create)
  - `GET /api/TodoLists` (List)
  - `GET /api/TodoLists/{id}` (Detail)
  - `PUT /api/TodoLists/{id}` (Update)
  - `DELETE /api/TodoLists/{id}` (Delete)
- **State Management**: `flutter_bloc` (Cubit).
- **Navigation**: `go_router` (`RouteNames.todoLists = '/todo-lists'`).
- **HTTP**: `DioClient` with Bearer auth interceptor.

---

## 2. Architecture & File Structure

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart (add todoLists endpoints)
│   ├── router/
│   │   ├── route_names.dart (add todoLists)
│   │   ├── app_router.dart (register /todo-lists route)
│   └── utils/
│       └── color_utils.dart (hex <-> Color converter)
└── features/
    └── todo_lists/
        ├── data/
        │   ├── models/
        │   │   ├── todo_list_response_dto.dart
        │   │   ├── create_todo_list_request.dart
        │   │   ├── update_todo_list_request.dart
        │   │   └── todo_lists_collection_response_dto.dart
        │   ├── datasources/
        │   │   └── todo_lists_remote_data_source.dart
        │   └── repositories/
        │       └── todo_lists_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── todo_list.dart
        │   └── repositories/
        │       └── todo_lists_repository.dart
        └── presentation/
            ├── cubits/
            │   ├── todo_lists_cubit.dart & todo_lists_state.dart
            │   └── todo_list_form_cubit.dart & todo_list_form_state.dart
            ├── screens/
            │   └── todo_lists_screen.dart
            └── widgets/
                ├── todo_list_card.dart
                ├── color_picker_grid.dart
                └── todo_list_form_modal.dart
```

---

## 3. Implementation Phases

1. **Constants & Utilities**:
   - `ApiConstants.todoLists = '/api/TodoLists'`
   - `RouteNames.todoLists = '/todo-lists'`
   - `ColorUtils` helper for hex `#RRGGBB` conversions and preset palette.
2. **Data Layer**:
   - DTOs and JSON serialization.
   - Remote data source implementing CRUD on `/api/TodoLists`.
   - Repository interface and implementation with error handling (RFC 7807 -> Failures).
3. **State Management**:
   - `TodoListsCubit`: Loads lists, creates, updates, and deletes lists with reactive state.
   - `TodoListFormCubit`: Manages form validation (name length 1-100, selected hex color) for create/edit.
4. **UI Presentation**:
   - `TodoListsScreen`: Pull-to-refresh list view, empty state, floating add button.
   - `TodoListCard`: Color badge/indicator, title, updated/created timestamp, edit and delete buttons.
   - `TodoListFormModal`: Bottom sheet with name input, preset color grid, and submit button.
   - Integration into `HomeScreen` with quick access navigation button.
5. **Testing & Verification**:
   - Unit tests for repository and cubits.
   - Widget tests for screen and form modal.
   - `flutter analyze` and `flutter test`.
   - Device verification on Samsung Galaxy A71.
