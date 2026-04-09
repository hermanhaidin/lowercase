# User Flow

## Onboarding
- Welcome screen → Continue → New Folder form → Create → Home
- New Folder: text field + "Store in iCloud" toggle
- Toggle determines which root gets the folder
- Create button disabled until folder name is typed

## Home View
- Tree view: folders as expandable accordions, notes as leaf rows
- Storage switcher pill in toolbar (leading) — always visible
- Bottom bar: expand/collapse toggle, sort button, + add note button
- Empty state: sad face icon + "No notes yet..." message
- Notes directly under root ("orphan" notes) appear after all folders

## Storage Switcher
- Tap toolbar pill → sheet with two options: "iCloud Drive", "On My iPhone"
- Selecting switches root, tree view refreshes
- Both options always visible even if only one root has content

## Sort
- Tap "Sort" in bottom bar → sheet with three criteria
- Name (a–z / z–a), Modified (new–old / old–new), Created (new–old / old–new)
- Active sort option shows checkmark

## Creating Notes
- Tap + in bottom bar → "Add note to..." sheet
- Three destination options:
  1. Root — note placed directly under current root
  2. New folder — inline text field for folder name, submit creates folder + note
  3. Existing folder — flat indented list of all folders/subfolders, tap to select
- After selecting destination → editor opens with new note
- Note naming: folder name contains "daily" → `YYYY.MM.DD`, otherwise → `untitled-N`

## Editor
- Toolbar: back arrow (leading), note title (center, white), ellipsis (trailing)
- Markdown-aware text editing (syntax visible, colored per markdown-formatting rules)
- Auto-saves on pause and background
- Typing state: scrollable quick actions bar appears above keyboard
- Back button → returns directly to home (skips select-folder sheet)

## Quick Actions
- Triggered by: long-press on note/folder in home, or ellipsis button in editor
- Sheet with three form sections:
  1. Share (notes only — opens system share sheet)
  2. Rename + Move to...
  3. Delete (accent-colored text)

## Rename
- From quick actions → sheet dismisses, name becomes inline editable text field
- Home: row text becomes input, keyboard appears, storage switcher hides, "Done" button appears at toolbar trailing
- Editor: toolbar title becomes input, keyboard appears, ellipsis hides, "Done" button appears at toolbar trailing

## Move To
- Opens "Move to..." sheet (same pattern as select-folder)
- Same three options: root, new folder, existing folder tree
- Selecting destination moves the item and dismisses the sheet

## Delete
- Delete option in quick actions → quick actions sheet dismisses, delete confirmation sheet appears
- Folder deletion warns about all contents being deleted
- Three buttons: "Delete and don't ask again", "Delete", "Cancel"
- Deletion goes to Files/Recently Deleted when possible

## Edge Cases & Rules
- Same-name renames are no-ops (sheet just dismisses)
- No-op moves allowed — selecting current parent just dismisses
- Moving a folder into itself or its descendants is invalid (excluded from destination list)
- If a move happens while note is open in editor, editor updates its URL silently
- Root directories are created lazily — only when first folder or note is added
- Slashes in new folder names create nested folders (e.g. `daily/work` creates `work` inside `daily`)
- If today's daily note already exists in a "daily" folder, creating a new note there opens the existing note instead
- Select-folder and move-to sheets share the same destination picker pattern
