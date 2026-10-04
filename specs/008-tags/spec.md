# Feature Specification: FEAT-08 — Tags & Categorization

**Feature Branch**: `008-tags-categorization`  
**Created**: 2026-10-03  
**Status**: Draft  
**Input**: User request: "diğer featura'a geç" -> FEAT-08 Tags & Categorization

---

## Overview

FEAT-08 enables cross-cutting task categorization via system-wide tags. Tags can be attached to and detached from tasks by task owners. Users can browse system tags, view tags attached to tasks, filter tasks by a specific tag with pagination, and admin users (`role == "Admin"`) can create new system tags.

---

## User Scenarios & Testing

### User Story 1 - System Tag Catalog & Task Tags View (Priority: P1)

As a user viewing a task or browsing tags, I want to see tags displayed as clean visual chips, so that I can immediately identify how tasks are categorized.

**Why this priority**:
Displaying tags is fundamental to categorization.

**Independent Test**:
Open a task detail screen and task card in task list; observe tag chips rendered with clear labels and colors/styling.

**Acceptance Scenarios**:
1. **Given** a task with tags attached, **When** viewed on the task card or detail screen, **Then** tag chips are displayed showing tag names.
2. **Given** a user loading system tags, **When** `GET /api/tags` is requested, **Then** all available tags in the system are retrieved as a `CollectionResponse<TagResponse>`.

---

### User Story 2 - Attach & Detach Tags on a Task (Priority: P1)

As a task owner, I want to attach existing system tags to my task or detach them, so that I can organize my tasks accurately.

**Why this priority**:
Organizing tasks by attaching/detaching tags is the core function of categorization.

**Independent Test**:
On the task detail screen, tap "Etiket Ekle" or manage tags, select an available tag to attach it (`POST /api/todoitems/{taskId}/tags/{tagId}`), observe tag chip added. Then tap remove on a tag (`DELETE /api/todoitems/{taskId}/tags/{tagId}`) and verify detachment.

**Acceptance Scenarios**:
1. **Given** a task where `isOwner == true`, **When** the user selects a system tag to attach, **Then** `POST /api/todoitems/{taskId}/tags/{tagId}` is executed, returning 200 OK, and the tag is added to the task.
2. **Given** an already-attached tag, **When** attach is called again, **Then** the call succeeds idempotently without error.
3. **Given** an attached tag, **When** the owner removes the tag, **Then** `DELETE /api/todoitems/{taskId}/tags/{tagId}` is called, returning 204 No Content, removing the tag from the task without deleting it from the system catalog.
4. **Given** a user who is NOT the owner (`isOwner == false`), **When** viewing the task, **Then** attach/detach controls are not permitted/disabled.

---

### User Story 3 - Browse Tasks by Tag (Priority: P1)

As a user, I want to view all tasks associated with a specific tag with pagination, so that I can focus on a particular project or category.

**Why this priority**:
Viewing all tasks belonging to a tag completes the categorization workflow.

**Independent Test**:
Tap on any tag chip (on a task card or detail screen), navigate to `TaggedTasksScreen`, observe paginated list of tasks matching the tag (`GET /api/tags/{tagId}/todoitems`).

**Acceptance Scenarios**:
1. **Given** a tag chip is tapped, **When** navigating to the tagged tasks view, **Then** `GET /api/tags/{tagId}/todoitems` is called with `page` and `pageSize`, displaying matching tasks.
2. **Given** more than 1 page of tagged tasks, **When** scrolling to bottom, **Then** next page is fetched and appended.
3. **Given** no tasks with this tag, **When** loaded, **Then** an informative empty state is shown.

---

### User Story 4 - Admin Tag Creation (Priority: P2)

As an Admin user, I want to create new tags in the system catalog, so that users can categorize tasks under new themes.

**Why this priority**:
System tag catalog expansion is restricted to Admins per security requirements.

**Independent Test**:
Log in as an Admin user, open the tag creation modal/dialog, enter a new tag name, tap create (`POST /api/tags`), and verify the new tag appears in the system tag list. Non-admin users do not see the create action (or receive a 403 Forbidden alert if attempted).

**Acceptance Scenarios**:
1. **Given** an authenticated user with `role == "Admin"`, **When** submitting a new tag name, **Then** `POST /api/tags` is called with `{"name": "..."}`, returning 201 Created with the new `TagResponse`.
2. **Given** a non-admin user (`role != "Admin"`), **When** checking the tag selector, **Then** the "Yeni Etiket Oluştur" button is hidden.

---

## Technical & Architectural Requirements

- **Clean Architecture**:
  - `features/tags/data`: models (`TagResponseDto`, `CreateTagRequest`), remote data source, repository implementation.
  - `features/tags/domain`: repositories (`TagsRepository`).
  - `features/tags/presentation`: cubits (`TagsCubit`, `TaggedTasksCubit`), screens (`TaggedTasksScreen`), widgets (`TagChip`, `TaskTagsSection`, `TagSelectorBottomSheet`, `CreateTagDialog`).
- **Endpoints**:
  - `GET /api/tags`
  - `POST /api/tags` (Admin only)
  - `GET /api/tags/{tagId}/todoitems` (Paginated)
  - `GET /api/todoitems/{taskId}/tags`
  - `POST /api/todoitems/{taskId}/tags/{tagId}` (idempotent)
  - `DELETE /api/todoitems/{taskId}/tags/{tagId}`
- **Security & RBAC**:
  - Check `UserProfile.role == 'Admin'` before displaying admin tag creation controls.
  - Check `task.isOwner` before displaying attach/detach tag controls.

