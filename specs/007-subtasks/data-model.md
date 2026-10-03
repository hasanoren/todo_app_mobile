# Data Model: FEAT-07 Subtasks (Checklist)

## Entities & Data Transfer Objects

### 1. `SubtaskResponseDto` (`SubTaskResponse`)
Represents an individual subtask item:

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID of the subtask |
| `taskId` | `String` | UUID of the parent task |
| `title` | `String` | Subtask title |
| `status` | `String` | "Open" or "Completed" |
| `createdAt` | `DateTime` | Created timestamp |
| `updatedAt` | `DateTime?` | Updated timestamp |

Helper getters:
- `bool get isCompleted => status.toLowerCase() == 'completed' || status == '1';`

### 2. `SubtasksCollectionResponseDto`
Unpaginated list wrapper:
```json
{
  "items": [ ... ]
}
```

### 3. `CreateSubtaskRequest`
DTO sent to `POST /api/todoitems/{taskId}/subtasks`:
```json
{
  "title": "Subtask title"
}
```

