# Architecture

## Folder Structure

```
lowercase/
├── Models/
│   ├── FileError.swift
│   ├── FileNode.swift
│   ├── FlatTreeRow.swift
│   ├── SortCriterion.swift
│   ├── SortOrder.swift
│   └── StorageRoot.swift
└── Services/
    ├── FileStore.swift
    ├── ICloudMonitor.swift
    └── NoteNamer.swift
```

## Models

**StorageRoot** — Enum with `.local` and `.iCloud` cases. Drives which root directory is scanned. Provides `displayName`, `icon`, and `isAvailable` for UI.

**FileNode** — Recursive tree struct representing a file or folder. Identity is `URL`. Holds `name`, `isFolder`, `dateCreated`, `dateModified`, and `children: [FileNode]`. Folders always have children (empty array if none); notes have no children.

**FlatTreeRow** — UI-optimized flat struct derived from FileNode. Adds `depth: Int` for tree indentation and `hasChildren: Bool` (avoids exposing the full child array). Constructed via `init(from:depth:)`.

**SortOrder** — Struct holding `criterion: SortCriterion` and `ascending: Bool`. The `select(_:)` method toggles direction for same criterion or resets to default for new criterion.

**SortCriterion** — Enum: `.name`, `.modified`, `.created`. Each case has a `defaultAscending` (name = true, dates = false).

**FileError** — LocalizedError enum thrown by FileStore, surfaced via `currentError`. Cases with associated values:
- `rootUnavailable`
- `alreadyExists(String)` — item name
- `invalidMove(String)` — reason
- `notFound(URL)` — file URL
- `readFailed(URL, underlying: Error)`
- `writeFailed(URL, underlying: Error)`

## Services

**FileStore** (`@Observable`, central service)
- Owns `activeRoot`, `rootChildren`, `sortOrder`, `expandedFolders`, `currentError`
- `flatRows` is computed from the tree + expansion state
- `loadTree()` scans the active root recursively, filtering for `.md` files and directories only
- Sorting always puts folders before notes, then sorts each group by current `SortOrder`
- CRUD: `createNote(in:)` returns `(url, isNew)` (isNew is false when a daily folder already has today's note), `createFolder(named:in:)`, `readNote(at:)`, `writeNote(_:to:)`, `trashItem(at:)`, `rename(at:to:)`, `moveItem(at:to:)`
- `allFolders(excluding:)` returns a flat list with depth for destination pickers
- `resolveRootURL()` — async, resolves active root URL (local path or iCloud container)
- `switchRoot(to:)` — switches active root, persists to UserDefaults, clears state, manages iCloud monitor, reloads tree
- `resort()` — re-sorts existing tree in memory without reloading from disk
- `toggleExpansion(for:)`, `expandAll()`, `collapseAll()` — folder expansion state
- All I/O wrapped in `NSFileCoordinator` via private `coordinated*` methods
- Owns `ICloudMonitor`; starts/stops monitoring on root switch

**ICloudMonitor** (`@Observable`)
- Uses `NSMetadataQuery` to detect iCloud changes, calls `onUpdate` closure (set by FileStore)
- Eagerly downloads `.md` files not yet local via `triggerDownloads()`
- `startMonitoring()` / `stopMonitoring()` control lifecycle

**NoteNamer** (static enum, no instances)
- `nextName(in:)` — folder name contains "daily" → `YYYY.MM.DD`, otherwise → `untitled-N`
- `dailyNoteExists(in:)` — returns existing daily note URL if today's already exists

## Data Flow

```
StorageRoot → FileStore.loadTree() → scans directory → [FileNode] tree
  → sortNodes() → folders first, then notes, by SortOrder
  → flattenTree() → [FlatTreeRow] using expandedFolders set → UI

Sort order changes → resort() → re-sorts existing tree in memory → flatRows rebuild
switchRoot(to:) → persists choice → clears state → starts/stops iCloud monitor → loadTree()
ICloudMonitor detects changes → triggers loadTree() → tree refreshes
```
