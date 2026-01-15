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
- Folder-based organization
- Renaming a note = renaming the file
- If notes end up directly under `~/lowercase` (e.g. moved via `Files`), treat them as “orphans”

## Home (tree) interaction

- Home is a compact tree; folders are accordions
- Expand / collapse all folders from Home
- Accordion expand uses `withAnimation` only (no extra transitions)
- Chevron rotates on expand / collapse
- No pressed highlight on folder rows
- Make the whole folder row tappable via `contentShape(.rect)`
- Show orphan notes below folders on Home

## Editor

- No live preview (for now)
- In-editor typing: `autocorrectionDisabled()` + `textInputAutocapitalization(.never)`
- Long-press on a note shows a text preview alongside the context menu

## Create notes

- New note flow: pick folder → editor
- Default new note name: `yyyy-mm-dd.md` or `untitled-1.md`
- If folder name contains `daily`, default to `yyyy-mm-dd.md`

## UI style

- Folder names + filenames use monospaced type
- App chrome (toolbar, safe area bar, context menus) uses the system font
- Prefer system monospaced over bundling `MonacoTTF`
- Use `ScaledMetric` over hardcoded padding; plain `padding()` / `padding(.horizontal)` is fine when it stays stable
- Multiple app color themes over time
- Settings are presented as a sheet
- Search view shows total folder + file counts (not shown by default elsewhere)
- Onboarding CTA is a full-width glass button: `buttonSizing(.flexible)` + `buttonStyle(.glassProminent)` + `controlSize(.large)`

## Implementation notes

- Tree UI uses recursive `View` structs (not recursive functions returning `some View`)