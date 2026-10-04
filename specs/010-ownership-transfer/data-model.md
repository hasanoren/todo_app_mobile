# Data Model: FEAT-10 — Ownership Transfer

## Entities & Models

### 1. `TransferRequestResponseDto`
Represents an asynchronous ownership transfer request between users.

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | `String` | Yes | Request UUID |
| `taskId` | `String` | Yes | Task UUID |
| `taskTitle` | `String` | Yes | Title of the task being transferred |
| `fromUserId` | `String` | Yes | Current owner's user ID |
| `fromUserEmail` | `String` | Yes | Current owner's email |
| `toUserId` | `String` | Yes | Designated new owner's user ID |
| `toUserEmail` | `String` | Yes | Designated new owner's email |
| `status` | `String` | Yes | Status enum: `Pending`, `Accepted`, `Rejected`, `Cancelled` |
| `createdAt` | `DateTime` | Yes | Creation timestamp |
| `respondedAt` | `DateTime?` | No | Timestamp of acceptance/rejection/cancellation |

### 2. `CreateTransferRequestDto`
Payload sent by the current owner to initiate a transfer.

| Field | Type | Required | Description |
|---|---|---|---|
| `newOwnerEmail` | `String` | Yes | Recipient user's email address |

### 3. `TransferActionResponseDto`
Confirmation message returned when accepting, rejecting, or cancelling a transfer request.

| Field | Type | Required | Description |
|---|---|---|---|
| `message` | `String` | Yes | Confirmation status message |

