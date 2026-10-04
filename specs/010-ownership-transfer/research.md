# Research: FEAT-10 — Ownership Transfer

## 1. Backend Endpoints Analysis

- `POST /api/todoitems/{taskId}/transfer-requests`
  - Body: `{ "newOwnerEmail": "new_owner@example.com" }`
  - Only task owner (`isOwner == true`) is allowed.
  - Returns `TransferRequestResponse` (`status: "Pending"`).

- `GET /api/transfer-requests/pending`
  - Returns `CollectionResponse<TransferRequestResponse>` with all incoming requests waiting for recipient's decision.
  - Supports badge count for notification indicator.

- `POST /api/transfer-requests/{requestId}/accept`
  - Called by recipient.
  - Ownership is formally transferred to the recipient (`isOwner` flips).
  - Returns `{ "message": "Transfer request accepted and ownership transferred." }`.

- `POST /api/transfer-requests/{requestId}/reject`
  - Called by recipient.
  - Status becomes `Rejected`. Task stays with current owner.
  - Returns `{ "message": "Transfer request rejected." }`.

- `POST /api/transfer-requests/{requestId}/cancel`
  - Called by original owner.
  - Status becomes `Cancelled`.
  - Returns `{ "message": "Transfer request cancelled." }`.

## 2. UI / UX Design & Navigation Flow

1. **Owner Initiation**:
   - In `TaskDetailScreen`, when `isOwner == true`, the AppBar menu or a dedicated button provides "Sahipliği Devret" (Transfer Ownership).
   - Dialog asks for recipient's email with validation.
   - On success, toast informs owner that the transfer request has been sent.

2. **Recipient Experience**:
   - A dedicated badge / icon on `HomeScreen` or `TasksScreen` shows the count of pending incoming transfer requests.
   - Tapping it navigates to `TransferRequestsScreen` (`/transfer-requests`).
   - Cards display sender, task title, and date.
   - "Kabul Et" and "Reddet" action buttons with quick confirmation.
   - Upon acceptance, task becomes owned by the recipient and appears in their task list.

