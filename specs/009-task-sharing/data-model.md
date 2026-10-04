# Data Model: FEAT-09 — Task Sharing & Member Access

## Entities & Models

### 1. `SharedUserResponseDto` / `SharedUserItemDto`
Represents a collaborator who has access to a shared task.

| Field | Type | Required | Description |
|---|---|---|---|
| `userId` | `String` | Yes | Collaborator user UUID |
| `email` | `String` | Yes | Collaborator email address |
| `sharedAt` | `DateTime` | Yes | Timestamp when the task was shared |

### 2. `ShareTaskRequest`
Request payload for sharing a task with another user.

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | `String` | Yes | Recipient user email address |

### 3. `ShareTaskResponseDto`
Response received upon successful share request.

| Field | Type | Required | Description |
|---|---|---|---|
| `message` | `String` | Yes | Server confirmation message |

### 4. `SharesCollectionResponseDto`
Wrapper for the list of shared collaborators.

| Field | Type | Required | Description |
|---|---|---|---|
| `items` | `List<SharedUserResponseDto>` | Yes | List of shared users |

