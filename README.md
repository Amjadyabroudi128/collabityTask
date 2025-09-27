# MyTasks — Flutter Demo (Task List)

A simple, polished task list screen demonstrating add/edit/delete, undo, confirmation dialogs, and swipe-to-dismiss — all with vanilla Flutter (`setState`).

---

## ✨ Features

* Add tasks via `TextFormField` (submit with Enter) or the ➕ icon
* Toggle completion with `Checkbox` (strikethrough style)
* Edit & Delete from a `PopupMenuButton` per row
* Swipe left to delete with `Dismissible` + SnackBar Undo
* Delete confirmation dialog from overflow menu
* Undo restore preserves list order
* Rounded `Card` list items, light elevation

---

## 🧱 Architecture & State

* **State container:** `_tasks` (in-memory `List<Map<String, dynamic>>`)
* **IDs:** monotonically increasing `_nextId` (fallback to timestamp for Undo)
* **State management:** `setState` (kept simple for demo)
* **Component ownership:** All logic in a single `StatefulWidget` (`_MyHomePageState`)

---

## 🔍 UX Details

* **Add:** trims input; ignores empty strings; clears field on add.
* **Submit:** `onFieldSubmitted` triggers `_addTask()` for keyboard-first flow.
* **Done state:** applies `TextDecoration.lineThrough` when checked.
* **Delete (swipe):** `Dismissible` → immediate remove + SnackBar with **Undo**.
* **Delete (menu):** shows `AlertDialog` for confirmation; on confirm, remove + SnackBar Undo.
* **Undo:** reinserts at original index with a new unique ID (timestamp) to avoid key collisions.
* **Feedback:** SnackBars for delete/undo and edit validation (no-change/empty).
* **Consistency:** Popup menu uses rounded corners; cards use `RoundedRectangleBorder`.

---

## 🧭 Interaction Flows

### Delete via Swipe

1. Swipe left → item dismissed
2. Remove from list → show SnackBar with **Undo**
3. Undo reinserts at prior index

### Delete via Menu (safe path)

1. Tap ⋯ → **Delete**
2. `AlertDialog` (Cancel/Delete)
3. On Delete → remove + SnackBar Undo

### Edit

1. Tap ⋯ → **Edit**
2. `AlertDialog` with prefilled `TextFormField`
3. **Save** validates: non-empty, changed text
4. Updates list + success SnackBar

---

## ♿ Accessibility & Usability

* `TextFormField` has hint text; supports keyboard submit
* Touch targets: ListTile + leading `Checkbox` are large
* Color choices rely on platform theme; respects high-contrast when theming applied
* Consider adding semantics labels and focus traversal for desktop/web

---

## 🛠️ Implementation Notes

* `Dismissible` needs a **stable** key: `ValueKey(task["id"])`
* Using `confirmDismiss` (currently returns `true`) lets you later gate deletion per direction or condition
* SnackBar `action` reinserts using the **captured** index & title to maintain order
* `mounted` checks guard SnackBar calls after dialogs
* Dialog `Navigator.pop` returns edited value for submit-on-enter flow
* Rounded corners: `OutlineInputBorder` & `RoundedRectangleBorder`

---

## 🧪 Testing Checklist

* Add trims whitespace; empty input ignored
* Checkbox toggles visual strikethrough and persists in list
* Swipe delete shows SnackBar; Undo restores at same index
* Menu delete shows confirm dialog; Cancel leaves list unchanged
* Edit rejects empty or unchanged text; accepts valid change
* Undo after multiple deletes works independently
* Rapid add/delete/edit doesn’t crash (key stability)

---

## 🚀 Running the Demo

```bash
flutter pub get
flutter run 
```

---

## 🔒 Known Limitations

* In-memory only; state resets on hot restart/app relaunch
* IDs are local-only; collisions avoided but not globally unique

---
