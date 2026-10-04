# Feature Specification: FEAT-09 — Task Sharing & Member Access

**Feature Branch**: `009-task-sharing`  
**Created**: 2026-10-04  
**Status**: Ready for Implementation  
**Input**: Feature breakdown sequence FEAT-09

---

## Overview

FEAT-09 enables collaborative task access by allowing task owners to share tasks with other registered users via email, manage active collaborators, and allow collaborators to voluntarily leave shared tasks. It also provides visual distinctions between owned and shared tasks in task lists and details.

---

## User Scenarios & Acceptance Criteria

### User Story 1 - View Collaborators & Visual Distinction (Priority: P1)
As a user (owner or collaborator), I want to see who has access to a task, and visually recognize shared tasks in my task list.

**Acceptance Criteria**:
1. On `TaskDetailScreen`, a dedicated `TaskSharesSection` lists all current collaborators with their email and date shared.
2. In `TaskCard`, tasks where `isOwner == false` display a "Paylaşıldı" / collaborator indicator badge.
3. In `TaskCard`, tasks where `isOwner == true` and `sharedWith.isNotEmpty` display a collaborator count icon.

---

### User Story 2 - Share Task by Email (Priority: P1)
As a task owner, I want to share my task with another user by entering their email address, so that we can collaborate on the task.

**Acceptance Criteria**:
1. Tapping "Kişi Ekle" opens a `ShareTaskDialog` with email input.
2. Form validates valid email format and non-empty.
3. Submitting sends `POST /api/todoitems/{taskId}/shares` with `{ "email": "..." }`.
4. On success, displays a SnackBar notification and refreshes the collaborators list.
5. On error (e.g. user not found or conflict), an actionable error message is shown.

---

### User Story 3 - Remove Collaborator (Owner Only) (Priority: P1)
As a task owner, I want to revoke a collaborator's access to my task when they no longer need it.

**Acceptance Criteria**:
1. Each collaborator tile has a delete/remove button visible only when `isOwner == true`.
2. Tapping delete shows a confirmation dialog.
3. Confirming executes `DELETE /api/todoitems/{taskId}/shares/{userId}`.
4. On success, the user is removed from the list and a confirmation SnackBar is displayed.

---

### User Story 4 - Leave Shared Task (Collaborator Only) (Priority: P1)
As a collaborator on a shared task, I want to remove myself from the task when my work is done.

**Acceptance Criteria**:
1. When `isOwner == false`, a "Paylaşımdan Ayrıl" (Leave Task) option/button is available.
2. Tapping it shows a confirmation dialog.
3. Confirming executes `DELETE /api/todoitems/{taskId}/shares/me`.
4. On success, displays a SnackBar and navigates back to `TasksScreen`, refreshing the task list.

