# Text Editor

Lowercase is a text editor, not a document editor.

## Core Principles

- Content is always plain text markdown
- File on disk is the single source of truth
- Editor never invents structure that is not present in text
- Writing > formatting

## Text Model

- Editor works on a single UTF-8 text buffer
- No hidden metadata
- No frontmatter
- No invisible control characters
- Line breaks are preserved exactly as typed
- External file edits must not silently rewrite content

## Cursor and Selection

- Cursor is always explicit and visible
- One insertion point
- Selections are standard text ranges
- Moving the cursor must never rewrite text

## Markdown Philosophy

- Markdown is syntax, not structure
- Editor understands markdown tokens

Allowed tokens `v0/v1`:

- Emphasis: `*italic*`, `**bold**` (syntax supported; no styling required in `v0`)
- Inline links: `[label](url)` (syntax supported; no rendering tweaks required in `v0`)
- Checkboxes: `- [ ]`, `- [x]` (syntax supported; no interactive glyph required in `v0`)
- Quotes: `> quote` (syntax supported; no styling required in `v0`)

Tokens outside this list are treated as plain text with no special behavior.

## Syntax-Aware Rendering Rules

Syntax-aware rendering is out of scope for `v0`.

- `v0` shows raw markdown as-is
- Bold/Italic/Link/Checkbox/Quote syntax is supported as text, but not styled
- Any styling or interactivity is deferred to `v1+`

## Editing Behavior

- Typing inserts characters exactly at cursor
- Deleting removes characters exactly at selection
- No automatic reformatting of surrounding text

Allowed lightweight helpers:

- Auto-pair for:
    - `() [] "" ''`
- Helpers must:
    - Operate in sync
    - Be undoable in one step

## Keyboard

- Auto-capitalization: **off**
- Auto-correction: **off**
- Smart quotes: **off**
- Text replacement: **off**

Capitalization is always intentional.

## Typography

- Editor text uses `MonacoTTF` at **18pt**
    - Pixel font is reserved for the writing surface
    - Keep sizes integer to avoid blurry rendering

- UI chrome (navigation, buttons, settings, menus) uses **system font** in `v0`
    - MonacoTTF has imperfect vertical metrics (baseline / line box), which causes misalignment in tight controls
    - Bold/italic styling is not supported in `v0` even if syntax exists
    - Revisit custom chrome typography after:
        - Pixel/bitmap icon set exists, and / or
        - Font file is revised to support correct baseline + bold + italic.

## Explicit Non-Goals

- No live preview
- No WYSIWYG blocks
- No rendered lists, headings, or tables
- No hidden structure
- No rich text storage

## Litmus Test

If a user opens the same file in another editor:

- The content is identical
- Nothing feels missing
- Nothing looks corrupted

If this is not true, the feature doesn't belong here.