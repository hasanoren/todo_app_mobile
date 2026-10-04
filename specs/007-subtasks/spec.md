# Feature Specification: FEAT-07 — Subtasks (Checklist)

**Feature Branch**: `007-subtasks`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User request: "diğer featura'a geç" -> FEAT-07 Subtasks (Checklist)

---

## Overview

FEAT-07 provides subtask (checklist item) management within a parent todo item. Users can break down complex tasks into granular actionable steps, view visual completion progress, add new subtasks, toggle completion states, and delete subtasks.

---

## User Scenarios & Testing

### User Story 1 - Subtask Browsing & Visual Progress (Priority: P1)

As a user viewing a task's details, I want to see a checklist of subtasks with a visual progress bar indicating how many steps are completed, so that I can track granular execution.

**Why this priority**:
Checklist visibility is essential for understanding what remains to be done on a task.

**Independent Test**:
Open a task detail screen, observe the subtask list and progress bar (e.g. "2/4 tamamlandı • %50"), and verify accurate counts.

**Acceptance Scenarios**:
1. **Given** a task detail screen, **When** the screen is loaded, **Then** `GET /api/todoitems/{taskId}/subtasks` is fetched, rendering the items in chronological order with status checkboxes.
2. **Given** subtasks with various statuses, **When** rendered, **Then** a progress bar shows `completedCount / totalCount` ratio.

---

### User Story 2 - Add New Subtask (Priority: P1)

As a task owner or collaborator, I want to add a new subtask by typing its title, so that I can quickly record actionable sub-items.

**Why this priority**:
Adding subtasks is required to populate and structure the checklist.

**Independent Test**:
Type "Dokümantasyonu yaz" in the quick-add input at the bottom of the checklist and tap add; verify the subtask appears immediately.

**Acceptance Scenarios**:
1. **Given** an active task detail screen, **When** entering a subtask title and submitting, **Then** `POST /api/todoitems/{taskId}/subtasks` is called with `{"title": "..."}`, and the new subtask is appended.
2. **Given** an empty title, **When** submit is attempted, **Then** no API call is made and a validation prompt is shown.

---

### User Story 3 - Toggle Subtask Completion (Priority: P1)

As a task owner or collaborator, I want to check off a subtask when finished, so that the checklist and progress reflect reality.

**Why this priority**:
Completing steps is the primary action on a checklist.

**Independent Test**:
Tap the checkbox next to an open subtask; verify status changes to Completed, text is struck through, and progress updates.

**Acceptance Scenarios**:
1. **Given** an open subtask, **When** user taps the checkbox, **Then** `PATCH /api/subtasks/{id}/complete` is called, status changes to Completed, and progress bar recalculates.
2. **Given** a completed subtask, **When** user taps again, **Then** `PATCH /api/subtasks/{id}/complete` is called, status reverts to Open.

---

### User Story 4 - Delete Subtask (Priority: P2)

As the task owner, I want to delete obsolete subtasks so that the checklist stays clean and relevant.

**Why this priority**:
Allows maintenance and cleanup of tasks.

**Independent Test**:
Tap the delete icon next to a subtask as the owner; confirm in dialog; verify `DELETE /api/subtasks/{id}` is executed and item disappears.

**Acceptance Scenarios**:
1. **Given** a task owner viewing subtasks, **When** tapping the delete button on a subtask, **Then** a confirmation dialog appears; upon confirming `DELETE /api/subtasks/{id}` is called.
2. **Given** a shared collaborator (not the owner), **When** viewing subtasks, **Then** the delete button is hidden/disabled per API rules.

---

## Edge Cases

- **Empty Checklist**: Display clean placeholder ("Henüz alt görev eklenmemiş. Aşağıdan ekleyebilirsiniz.").
- **Long Subtask Titles**: Text wraps gracefully across multiple lines without overflowing.
- **Rapid Toggling**: Optimistic state updates prevent UI jitter.
- **Network Failures**: Error SnackBar shown and state reverts on failure.

---

## Requirements

### Functional Requirements

- **FR-001**: System MUST fetch subtasks via `GET /api/todoitems/{taskId}/subtasks` returning `CollectionResponse<SubTaskResponse>`.
- **FR-002**: System MUST add subtasks via `POST /api/todoitems/{taskId}/subtasks` with `{ "title": string }`.
- **FR-003**: System MUST toggle subtask status via `PATCH /api/subtasks/{id}/complete`.
- **FR-004**: System MUST delete subtasks via `DELETE /api/subtasks/{id}` for task owners.
- **FR-005**: System MUST render progress indicator (`completed / total`) and strike-through styling.

---

## Success Criteria

- **SC-001**: Subtask checklist loads seamlessly within task detail screen.
- **SC-002**: Adding and toggling subtasks takes under 1 second with responsive UI.
- **SC-003**: Zero analyzer issues and 100% passing tests.

