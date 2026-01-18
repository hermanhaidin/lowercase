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
- Custom app themes are out of scope for v0

## Navigation

- Preserve the system back swipe gesture; avoid custom back buttons that disable it