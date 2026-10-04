# Phase 0: Research & Technical Validation — FEAT-07 Subtasks

## 1. API Analysis for Subtasks

### 1.1 Endpoints
- `POST /api/todoitems/{taskId}/subtasks`:
  - Request: `{"title": "string"}` (required)
  - Response: `201 Created` with `SubTaskResponse`
  - Authorization: Required (owner or shared user)
- `GET /api/todoitems/{taskId}/subtasks`:
  - Response: `200 OK` with unpaginated `CollectionResponse<SubTaskResponse>`:
    ```json
    {
      "items": [
        {
          "id": "uuid",
          "taskId": "uuid",
          "title": "Subtask title",
          "status": "Open", // or "Completed"
          "createdAt": "2026-10-01T...",
          "updatedAt": null
        }
      ]
    }
    ```
  - Authorization: Required (owner or shared user)
- `PATCH /api/subtasks/{id}/complete`:
  - Request: No body
  - Response: `200 OK` with updated `SubTaskResponse` (status toggled)
  - Authorization: Required (owner or shared user)
- `DELETE /api/subtasks/{id}`:
  - Request: No body
  - Response: `204 No Content`
  - Authorization: Required (owner only)

### 1.2 Architectural Placement
- Feature directory: `lib/features/subtasks/`
  - `data/models/subtask_response_dto.dart` (or re-exported from tasks DTO if suitable, but clean feature isolation recommends having its own DTO / collection wrapper)
  - `data/models/subtasks_collection_response_dto.dart`
  - `data/models/create_subtask_request.dart`
  - `data/datasources/subtasks_remote_data_source.dart`
  - `data/repositories/subtasks_repository_impl.dart`
  - `domain/repositories/subtasks_repository.dart`
  - `presentation/cubits/subtasks_cubit.dart` & `subtasks_state.dart`
  - `presentation/widgets/subtasks_section.dart` & `subtask_item_tile.dart`
- In `TaskDetailScreen`:
  - Integrate `SubtasksSection` embedded under the task metadata.
  - Takes `taskId` and `isOwner`.
  - Provides inline text field for adding subtasks, checkboxes for toggling, progress indicator, and delete buttons.

