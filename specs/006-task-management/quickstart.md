# Quickstart: FEAT-06 Task Management

## Step-by-Step Verification on Device (Samsung Galaxy A71)

### 1. View Tasks Screen
- Launch app.
- Tap "Tüm Görevler" from Home screen or tap into a specific list from "Görev Listelerim".
- Verify tasks load in a clean list with title, priority badge, and completion checkbox.

### 2. Create Task
- Tap "+" FAB button.
- Enter title "Sprint Planlama Toplantısı".
- Set priority to "High".
- Set due date to tomorrow.
- Select an existing list (e.g. "İş").
- Tap "Oluştur".
- Verify the modal closes, a success SnackBar appears, and the new task is at the top of the list.

### 3. Quick Complete Toggle
- Tap the checkbox on a task card.
- Verify status changes to completed (strike-through text, green checkmark icon).
- Tap again to revert to open.

### 4. Search & Filter
- Type "Sprint" into the search bar; verify debounced filtering.
- Open filter sheet; filter by "Açık" (Open) or "Yüksek" (High) priority.
- Verify list updates immediately.

### 5. Detail & Edit
- Tap the task card to navigate to `TaskDetailScreen`.
- Verify full details (due date, priority, description, list name, creation date).
- Tap "Düzenle" button; update title and description; tap "Kaydet".
- Verify updated values reflect immediately on detail screen and parent list.

### 6. Soft Delete
- Tap "Sil" icon/button; confirm dialog.
- Verify deletion succeeds and navigates back / removes item.
