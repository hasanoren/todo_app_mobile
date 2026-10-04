# Quickstart: FEAT-09 — Task Sharing & Member Access

1. Open a task detail screen where `task.isOwner == true`.
2. Scroll to the "Paylaşılan Kullanıcılar" (Task Collaborators) section.
3. Tap "Kişi Ekle" / "Paylaş".
4. Enter a valid user email (e.g., `colleague@example.com`).
5. Observe optimistic/immediate update in the collaborators list and success toast.
6. To remove a collaborator, tap the delete icon next to their email; confirm in the dialog; observe removal.
7. As a collaborator (`isOwner == false`), tap "Paylaşımdan Ayrıl"; confirm; observe removal from task and automatic return to task list.

