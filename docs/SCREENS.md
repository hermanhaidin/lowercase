# Screens

## Navigation graph

```
app launch
│
├─ (no directory exists) → onboarding
│   └─ create folder → home
│
└─ (directory exists) → home
    ├─ tap file → editor (pushed)
    │   └─ tap back → home
    ├─ long-press file → quick actions: rename, move to, delete (sheet medium detent)
    │   ├─ tap rename → filename (inline)
    │   ├─ tap move to → folder picker (sheet)
    │   │   ├─ tap new folder → create folder (inline) → home (note moved)
    │   │   ├─ tap folder → home (note moved)
    │   │   └─ tap sort → sort options (sheet medium detent)
    │   │   └─ tap cancel, swipe down → home
    │   └─ tap delete → delete confirmation (sheet medium detent)
    │       ├─ tap delete and don't ask again → home (note deleted, won't appear again)
    │       ├─ tap delete → home (note deleted)
    │       └─ tap cancel, scrim, swipe down → home
    ├─ tap expand / collapse → expand / collapse all folders
    ├─ tap sort → sort options: name, modified, created (sheet medium detent)
    │   ├─ tap sort option → home (sort applied)
    │   └─ tap scrim, swipe down → home
    ├─ tap storage switcher → select storage (sheet medium detent)
    │   ├─ tap directory (on my iphone), scrim, swipe down → home
    │   └─ tap settings → settings (pushed)
    │       └─ tap back → home
    └─ tap `+` → select folder (pushed)
        ├─ tap new folder → create folder (inline) → editor (pushed, keyboard up)
        └─ tap folder → editor (pushed, keyboard up)
            ├─ tap back → home
            └─ tap ellipsis → quick actions: rename, move to, delete (sheet medium detent)
                ├─ tap rename → filename (sheet, keyboard up)
                │   ├─ tap save → editor (new name in principal title, keyboard down)
                │   └─ tap cancel, scrim, swipe down → editor (keyboard down)
                ├─ tap move to → folder picker (sheet)
                │   ├─ tap new folder → create folder (inline) → editor (note moved, keyboard down)
                │   ├─ tap folder → editor (note moved, keyboard down)
                │   └─ tap cancel, swipe down → editor (keyboard down)
                └─ tap delete → delete confirmation (sheet medium detent)
                    ├─ tap delete and don't ask again → home (note deleted, won't appear again)
                    ├─ tap delete → home (note deleted)
                    └─ tap cancel, scrim, swipe down → editor (keyboard down)
            
```

## Core views

When breaking views up prefer `View` structs over computed properties or functions returning `some View`

- `~/Views/CreateNote/`
  - `SelectFolderView.swift` - select folder to put a new note in (pushed)
    - `FolderPickerListView` - new folder button + list all folder picker tree views
    - `FolderPickerTreeView` - folder picker tree view with one depth of subfolders and notes (recursive)
    - `FolderNameInputRow` - new folder name input (inline)
    - `FolderPickerRow` - folder picker in a tree view (indent + SF symbol + folder name + disclosure chevron)

- `~/Views/Onboarding/`
  - `OnboardingView.swift` - explain filesystem-first model, initiate first folder creation
  - `CreateFolderView.swift` - name first folder and choose storage location (pushed)

- `~/Views/Settings/`
  - `StorageSwitcherView.swift` - switch storage or access settings (modal)
    - `StorageOptionButton` - storage option button (SF symbol + title + checkmark if selected)
  - `SettingsView.swift` - app-level preferences (pushed)

- `~/Views/UserActions/`
  - `SortByView.swift` - select sorting method (modal)
    - `SortOptionButton` - sort option button (title + detail + checkmark if selected)
  - `QuickActionsView.swift` - list of quick actions, such as rename, move to, delete (modal)
    - `QuickActionButton` - quick action button
  - `EditFileNameView.swift` - rename folder or note (modal)
  - `MoveToFolderView.swift` - select folder where you want to move folder / note (modal)
    - `FolderPickerListView` - new folder button + list all folder picker tree views
    - `FolderPickerTreeView` - folder picker tree view with one depth of subfolders and notes (recursive)
    - `FolderNameInputRow` - new folder name input (inline)
    - `FolderPickerRow` - folder picker in a tree view (indent + SF symbol + folder name + disclosure chevron)
  - `DeleteFileView.swift` - confirm deletion of a folder or note (modal)

- `~/Views/`
  - `HomeView.swift` - browse folders and notes (pushed)
    - `FolderListView` - list all folder tree views + orphan notes
    - `FolderTreeView` - folder tree view with one depth of subfolders and notes (recursive)
    - `FolderRow` - folder accordion row in a tree view (indent + accordion chevron + SF symbol + folder name)
    - `NoteRow` - note row in a tree view (indent + SF symbol + filename)
  - `EditorView.swift` - edit a single note (pushed)