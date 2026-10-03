# Research: FEAT-08 — Tags & Categorization

## 1. Tag Endpoints Structure
The API provides two endpoints that return tags:
- `GET /api/tags` -> All system tags
- `GET /api/todoitems/{taskId}/tags` -> Tags attached to a given task

Both return a list of tags. In the backend, unpaginated collections are typically wrapped in `{ "items": [...] }` or returned directly as a JSON array. Our `TagsCollectionResponseDto` should robustly handle both formats (like `SubtasksCollectionResponseDto` and `TodoListsCollectionResponseDto`).

## 2. Paginated Tasks by Tag
`GET /api/tags/{tagId}/todoitems?page=1&pageSize=20` returns `PaginatedResponse<TodoItemResponse>`. We already have `PaginatedTodoItemsResponseDto` and `TodoItemResponseDto` implemented in `features/tasks/data/models/`. We can reuse `PaginatedTodoItemsResponseDto` directly for parsing.

## 3. Role Checking for Admin Actions
`UserProfileResponseDto` has a `role` field. When `profile.role.toLowerCase() == 'admin'`, the user is authorized to create system tags. If a regular user attempts `POST /api/tags`, the backend returns HTTP 403 Forbidden.

## 4. Attaching & Detaching Semantics
- `POST /api/todoitems/{taskId}/tags/{tagId}`: Attaches a tag. Returns 200 OK with `{"message": "Tag successfully attached."}`. The operation is idempotent: attaching an existing tag is a no-op returning 200 OK.
- `DELETE /api/todoitems/{taskId}/tags/{tagId}`: Detaches a tag from the task. Returns 204 No Content. Crucially, the tag itself remains intact in the global system catalog.

