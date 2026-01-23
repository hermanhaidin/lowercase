# Decisions

Running list of product + technical decisions. Keep entries short.

## Product

- One-time purchase (no subscription)
- No account required
- Audience is comfortable with Markdown
- Users own their notes; the app is “just” an editor

## Storage

- Notes are plain `.md` files under `~/lowercase`
- The `Files` app / filesystem is source of truth
- Each root directory (`iCloud Drive/lowercase`, `On My iPhone/lowercase`) can only be created once
- Custom paths (e.g. Dropbox) are out of scope for v0
- Storage switcher is always visible even with one directory
- Folder-based organization
- Renaming a note = renaming the file
- Delete moves items to Files → Recently Deleted when possible; falls back to permanent delete
- If notes end up directly under `~/lowercase` (e.g. moved via `Files`), treat them as "orphans"
- Users should enable "keep downloaded" for iCloud folders to ensure offline access

## Onboarding

- Shown when no lowercase directory exists or lowercase directories are empty

## Home (tree) interaction

- Home is a compact tree; folders are accordions
- Expand / collapse all folders from Home
- Accordion expand uses `withAnimation` only (no extra transitions)
- Chevron rotates on expand / collapse
- No pressed highlight on folder rows
- Make the whole folder row tappable via `contentShape(.rect)`
- Show orphan notes below folders on Home
- Long-press folder or note file → sheet with quick actions: rename, move to, delete
- Delete confirmation is one reusable sheet for folders and notes

## Editor

- Full screen, no line numbers
- No live preview (for now)
- Saves automatically on pause and background
- In-editor typing: `autocorrectionDisabled()` + `textInputAutocapitalization(.never)`
- On navigate away from editor: if filename is unchanged (still `untitled-N.md` or `yyyy-mm-dd.md`) and content is empty → delete file automatically

## Create notes

- New note flow: pick folder → editor
- Default new note name: `yyyy-mm-dd.md` or `untitled-N.md`
- If folder name contains `daily`, default to `yyyy-mm-dd.md`

## UI style

- Everything in lowercase + monospaced type (UI strings, titles, app chrome)
- System monospaced over bundling `MonacoTTF`
- Use `ScaledMetric` over hardcoded padding; plain `padding()` / `padding(.horizontal)` is fine when it stays stable
- Search view shows total folder + file counts (not shown by default elsewhere)
- Onboarding CTA is a full-width glass button: `buttonSizing(.flexible)` + `buttonStyle(.glassProminent)` + `controlSize(.large)`
- Home bottom actions use `safeAreaBar(edge: .bottom)` to avoid SwiftUI top + bottom toolbar conflicts
- Avoid mixing top and bottom toolbar items in the same view; use `safeAreaBar` for bottom controls
- Custom app themes are out of scope for v0

## Toolbar animations

- To animate between toolbar buttons (e.g. "sort" ↔ "done"), use separate `ToolbarItem` blocks with a shared `glassEffectID`
- Attach `glassEffectID` to the `Button`, not its label content
- Wrap the state change that triggers the toolbar switch in `withAnimation` — otherwise the transition is instant
- Use a local `@Namespace` for glass effect IDs scoped to the view

## Navigation

- Preserve the system back swipe gesture; avoid custom back buttons that disable it
- Use a single typed route enum + a single `NavigationPath`; prefer `navigationDestination(for:)` + `NavigationLink(value:)` for stack pushes
- Present `SelectFolderView` as a sheet, then push `EditorView` from Home so back always returns to Home