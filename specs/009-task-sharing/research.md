# Research: FEAT-09 — Task Sharing & Member Access

## 1. Backend API & Contract Analysis

- `POST /api/todoitems/{taskId}/shares`
  - Takes `{ "email": "friend@example.com" }`
  - Only the task owner (`isOwner == true`) is authorized.
  - Returns `{ "message": "Task successfully shared." }`
  - Returns `404 Not Found` if user does not exist or task does not exist.
  - Returns `400 Bad Request` or `409 Conflict` if already shared with that user or sharing with oneself.

- `GET /api/todoitems/{taskId}/shares`
  - Returns a collection wrapper `{"items": [...]}` or a direct array.
  - Returns all shared collaborators on the task.
  - Authorized for both the owner and any collaborator who has access.

- `DELETE /api/todoitems/{taskId}/shares/{userId}`
  - Removes collaborator `userId` from the task.
  - Owner only.
  - Returns `204 No Content`.

- `DELETE /api/todoitems/{taskId}/shares/me`
  - Current collaborator voluntarily leaves the shared task.
  - Returns `204 No Content`.

## 2. Business Rules & UI Patterns

1. **Owner Permissions**:
   - Owner can add collaborators by email.
   - Owner can remove any collaborator.
   - Owner can see all collaborators.
   - Owner cannot "leave" via `/shares/me` (owner uses ownership transfer or delete task).

2. **Collaborator Permissions**:
   - Collaborators can view the task, complete/toggle subtasks, view collaborators.
   - Collaborators **cannot** edit core task fields, toggle task completion, or delete the task.
   - Collaborator can leave the shared task via `DELETE /api/todoitems/{taskId}/shares/me`. Upon leaving, they lose access, and the UI should navigate back to the tasks list and refresh.

3. **List & Card Visual Distinction**:
   - Shared tasks show a distinctive "Paylaşıldı" / "Paylaşılan" badge or indicator.
   - Tasks owned by the user show a collaborator avatar/count if shared.

