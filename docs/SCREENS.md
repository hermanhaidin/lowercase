# Screens

Navigation flow and screen definitions for lowercase `v0`.


## 1. Onboarding (first launch only)

Shown once when no lowercase directory exists.

**Purpose:** Explain filesystem-first model, create initial directory.

**Elements:**
- Headline: "your thoughts are yours..."
- Body: "lowercase stores notes as files on your device" / "open them anywhere, even offline"
- `Create New Folder` button → Create Folder screen

v1+: "Use Existing Folder" button for custom paths (punted)

**Exit condition:** User creates a folder → navigate to Home.


## 2. Create Folder (New Folder)

**Purpose:** Name a new folder and choose storage location.

**Elements:**
- Title: "New Folder"
- Text field: folder name (placeholder: "folder name e.g. daily")
- Toggle: "store in iCloud" (default: on)
- Helper text: "this cannot be changed later"
- `Back` button → Onboarding
- `Create` button → creates folder, navigates to Home

**Paths created:**
- iCloud on: `iCloud Drive/lowercase/{name}/`
- iCloud off: `On My iPhone/lowercase/{name}/`

**Edge cases:**
- Empty name → disable Create button
- Duplicate name → show inline error


## 3. Home

**Purpose:** Browse folders and notes.

**Layout:** Expandable folder list (accordion style).

### Toolbar

- Left: storage switcher (`iCloud ▼` / `On My iPhone ▼`)
- Right: `Settings` button, `...` button (sort menu)

### Storage Switcher Behavior

Switcher is always visible, even with one directory.

Tapping reveals a menu:
- List of existing directories (iCloud, local) — tap to switch
- `Create Local Directory` — only if `On My iPhone/lowercase` doesn't exist
- `Create iCloud Directory` — only if `iCloud Drive/lowercase` doesn't exist
- If both directories exist, no create options shown

Rules:
- Each root directory (`iCloud Drive/lowercase`, `On My iPhone/lowercase`) can only be created once
- Custom paths (e.g. Dropbox) are out of scope for v0

### List

- Folders: tap to expand/collapse, shows nested files
- Files: tap to open → Editor
- Long-press folder/file → context menu:
  - Rename
  - Move to...
  - Delete

### Notes Not in Any Folder

If `.md` files exist directly in root (`iCloud Drive/lowercase/*.md`), show them in a separate section below folders:
- Header: "N notes not in any folder"
- Notes displayed with `?` icon to indicate orphan status
- Tap to open → Editor
- Long-press → same context menu (Rename, Move to..., Delete)

This handles the edge case where users move notes to root via Files.app.

### Sorting

Accessed via `...` button in toolbar. Applies to all folders and files.

**Sort options:**
- Name (A → Z / Z → A)
- Modified (New → Old / Old → New)
- Created (New → Old / Old → New)

Sort preference persists across sessions.

### Stats Footer

Below the folder/file list, show summary:
- "X folders: Y notes"
- If root-level notes exist: "N notes not in any folder"

### FAB (floating action button)

`+` button opens folder picker sheet directly (no menu). Goal is notes, not folders.

### New Note Flow

**If folders exist:**
1. Tap `+`
2. Resizable sheet appears ("New Note") with:
   - `+ new folder` button at top
   - Hierarchical folder list (current root only, nested folders expanded)
3. User taps folder name → sheet dismisses, Editor opens with new empty note
4. User taps `+ new folder` → inline folder name input, then auto-navigate to Editor with new note

**If no folders exist** (edge case — user manually deleted all folders):
1. Tap `+`
2. Prompt to create new folder first
3. After folder is created → auto-navigate to Editor with new note in that folder

### New Folder Flow

Folders are created as a side effect of the "New Note" or "Move to..." flows:
1. Open "New Note" or "Move to..." sheet
2. Tap `+ new folder` at top of list
3. Inline folder name input appears
4. Type name, confirm → folder created in current root

**Filename rules:**
- If folder name contains "daily" (e.g. `daily`, `daily-log`, `my-daily-notes`): filename is `yyyy-mm-dd.md`
- Otherwise: filename is `untitled-1.md` (increment if exists)

**Filepath display:**
- v0: not shown
- v1+: optional nicety to show path in Editor

### Search

Deferred to v1. Users should be able to search by filename and content.

### Empty State

When no folders or notes exist:
- Centered text: "no notes yet..." / "start by adding a note"
- Stats: "0 folders: 0 notes"
- Full-width "Add Note" button at bottom (not FAB)


## 4. Editor

**Purpose:** Edit a single note.

### Toolbar

- `Back` button → Home
- Title: filename (tappable to rename inline)
- `...` button → context menu:
  - Rename
  - Move to...
  - Delete

### Body

- Plain text editor
- MonacoTTF 18pt
- Full screen, no line numbers

### Keyboard Accessory

- v0: hide keyboard button only
- v1+: quick actions (like Apple Notes)

### Auto-Save

- Saves automatically on pause and background
- No save button
- No save indicator in v0 (consider for v1+ as optional nicety alongside char count)

### Auto-Delete Empty Files

On navigate away from Editor:
- If filename is unchanged (still `untitled-N.md` or `yyyy-mm-dd.md`) AND content is empty → delete file automatically

This prevents accumulation of empty untitled notes from accidental taps.


## 5. Settings

**Purpose:** App-level preferences.

**Options (v0):**
- Appearance: light / dark / system
- Auto-delete empty files: toggle (default: on)

**Navigation:** Modal or pushed from Home.


---

## Navigation Graph

```
app launch
│
├─ (no directory exists) → Onboarding
│   └─ Create Folder → Home
│
└─ (directory exists) → Home
    ├─ tap file → Editor
    │   └─ Back → Home
    ├─ tap `+` → New Note sheet
    │   ├─ tap folder → Editor (new note)
    │   └─ tap `+ new folder` → create folder → Editor (new note)
    ├─ tap Settings → Settings
    │   └─ Back → Home
    ├─ tap `...` → Sort menu
    ├─ tap switcher → switch directory / create directory
    └─ long-press → context menu (Rename / Move to... / Delete)
```


---

## v0 Scope

| Feature | v0 | v1+ |
|---------|:--:|:---:|
| Onboarding | ✓ | |
| Create folder (onboarding) | ✓ | |
| Use existing folder | ✗ | custom paths, Dropbox |
| Storage switcher | ✓ | |
| Create iCloud/local directory | ✓ | |
| Expandable folder list | ✓ | |
| New folder (via sheet) | ✓ | |
| New note (folder picker sheet) | ✓ | |
| Daily folder naming (`yyyy-mm-dd`) | ✓ | |
| Sorting (via `...` menu) | ✓ | |
| Notes not in any folder | ✓ | |
| Search | ✗ | filename + content |
| Inline title rename | ✓ | |
| Context menu (long-press) | ✓ | |
| Move to... (same root) | ✓ | cross-root |
| Share | ✗ | v1+ |
| Keyboard accessory | hide only | quick actions |
| Auto-save | ✓ | |
| Save indicator | ✗ | optional |
| Auto-delete empty files | ✓ | |
| Settings: appearance | ✓ | |
| Settings: auto-delete toggle | ✓ | |
| Char count | ✗ | v1+ |
| Gallery view | ✗ | v1+ |
| Custom themes | ✗ | v1+ |
| Split view (iPad/Mac) | ✗ | v2+ |


---

## Platform Notes

- v0 targets iOS only
- macOS and iPadOS (v2+) will feature split view for two notes side-by-side
- Users should enable "keep downloaded" for iCloud folders to ensure offline access


## Typography Notes

- **Chrome UI (v0):** Normal case for buttons, titles, menu items ("Settings", "Back", "New Folder")
- **Content text:** lowercase in pixel font (MonacoTTF 18pt)
- **Rationale:** Pixel font needs refinement before using in chrome. Revisit in v1+ once custom typography is finalized.

