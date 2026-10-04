# Implementation Plan: FEAT-10 — Ownership Transfer

**Feature Branch**: `010-ownership-transfer`  
**Spec**: [specs/010-ownership-transfer/spec.md](spec.md)

---

## 1. Architecture & Layering

### 1.1 Data Layer (`lib/features/ownership_transfer/data/`)
- `models/create_transfer_request_dto.dart`: Payload for transfer initiation (`newOwnerEmail`).
- `models/transfer_request_response_dto.dart`: Full DTO for transfer request items.
- `models/transfer_requests_collection_response_dto.dart`: Collection wrapper for pending list.
- `models/transfer_action_response_dto.dart`: Message response for accept/reject/cancel.
- `datasources/ownership_transfer_remote_data_source.dart`:
  - `Future<TransferRequestResponseDto> createTransferRequest(String taskId, String newOwnerEmail)`
  - `Future<List<TransferRequestResponseDto>> getPendingTransferRequests()`
  - `Future<String> acceptTransferRequest(String requestId)`
  - `Future<String> rejectTransferRequest(String requestId)`
  - `Future<String> cancelTransferRequest(String requestId)`
- `repositories/ownership_transfer_repository_impl.dart`: Implementation mapping Dio exceptions to `ServerFailure` / `NetworkFailure`.

### 1.2 Domain Layer (`lib/features/ownership_transfer/domain/`)
- `repositories/ownership_transfer_repository.dart`: Interface definition.

### 1.3 State Management (`lib/features/ownership_transfer/presentation/cubits/`)
- `pending_transfers_cubit.dart` & `pending_transfers_state.dart`:
  - `loadPendingTransfers()`
  - `acceptTransfer(String requestId)`
  - `rejectTransfer(String requestId)`
  - Provides count for badge notification.
- `transfer_request_cubit.dart` & `transfer_request_state.dart`:
  - Handles task owner initiating transfer or cancelling.

### 1.4 Presentation & UI (`lib/features/ownership_transfer/presentation/`)
- `widgets/transfer_ownership_dialog.dart`: Dialog in `TaskDetailScreen` to enter recipient email.
- `widgets/transfer_request_card.dart`: Visual card showing request info with "Kabul Et" and "Reddet" buttons.
- `screens/transfer_requests_screen.dart`: Screen displaying pending requests list.
- Badged action icon in AppBars (Home and Tasks screens) navigating to `transferRequests`.

### 1.5 Integration & DI
- Endpoints in `ApiConstants`:
  - `taskTransferRequests(taskId)`
  - `transferRequestsPending`
  - `transferRequestAccept(requestId)`
  - `transferRequestReject(requestId)`
  - `transferRequestCancel(requestId)`
- Register `OwnershipTransferRepository` and `PendingTransfersCubit` in `main.dart`.
- Register route `/transfer-requests` in `app_router.dart`.
- Unit tests in `test/features/ownership_transfer/ownership_transfer_test.dart`.

