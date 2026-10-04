# Feature Specification: FEAT-10 — Ownership Transfer

**Feature Branch**: `010-ownership-transfer`  
**Created**: 2026-10-04  
**Status**: Ready for Implementation  
**Input**: Feature breakdown sequence FEAT-10

---

## Overview

FEAT-10 facilitates formal task handover between users through an asynchronous request, accept, reject, and cancel workflow. The task owner can initiate transfer by providing the recipient's email address. The recipient receives the pending request, views it with a notification indicator, and chooses to accept (which transfers task ownership) or reject. The owner can also cancel pending outgoing requests.

---

## User Scenarios & Acceptance Criteria

### User Story 1 - Initiate Ownership Transfer (Priority: P1)
As a task owner, I want to initiate transfer of my task to another user by entering their email address.

**Acceptance Criteria**:
1. When `isOwner == true` on `TaskDetailScreen`, an action "Sahipliği Devret" is available.
2. Form dialog validates email format and requires non-empty.
3. Submitting triggers `POST /api/todoitems/{taskId}/transfer-requests` with `{ "newOwnerEmail": "..." }`.
4. On success, a SnackBar informs the user that the transfer request was created.
5. On error (e.g. user not found or conflict), an actionable error message is shown.

---

### User Story 2 - View Pending Incoming Transfer Requests (Priority: P1)
As a recipient user, I want to see how many pending requests I have and view them on a dedicated screen.

**Acceptance Criteria**:
1. On `HomeScreen` and `TasksScreen`, an action icon with a badge shows the number of pending incoming transfer requests.
2. Tapping it opens `TransferRequestsScreen` requesting `GET /api/transfer-requests/pending`.
3. Displays a list of incoming transfer requests with task title, sender email, and timestamp.
4. When no requests are pending, displays a clean empty state.

---

### User Story 3 - Accept or Reject Transfer Request (Priority: P1)
As a recipient user, I want to accept or reject an incoming task transfer request.

**Acceptance Criteria**:
1. Each request card has "Kabul Et" and "Reddet" action buttons.
2. Tapping "Kabul Et" executes `POST /api/transfer-requests/{requestId}/accept`, removes the request from the list, updates badge count, and shows a success toast.
3. Tapping "Reddet" executes `POST /api/transfer-requests/{requestId}/reject`, removes the request from the list, and updates badge count.

---

### User Story 4 - Cancel Outstanding Transfer Request (Priority: P2)
As an owner who sent a transfer request, I want to cancel it if sent by mistake or no longer needed.

**Acceptance Criteria**:
1. If an active transfer request exists, the owner can cancel it via `POST /api/transfer-requests/{requestId}/cancel`.
2. On success, confirmation toast is shown.

