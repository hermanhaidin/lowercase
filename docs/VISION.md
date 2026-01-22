## 1. Concept

- **App name** — lowercase (with lowercase `l`)
- **Category** — productivity

Lowercase is a fast, local-first notes app for people who think in text and files. Notes are plain markdown, stored visibly on your devices, and never locked behind subscriptions or sync servers.

Key principles:

- Storage
    - Files = `.md` in a visible folder, e.g. `iCloud Drive/lowercase`
    - App doesn't own your sync
- Format
    - Pure markdown, no weird frontmatter
- Design vibe
    - Everything in lowercase (UI strings, default titles)
    - Ultra minimal, keyboard-first
    - Terminal-inspired
- Scope `v0`
    - Text only, no complex embeds or live preview
    - Multi-folders


## 2. Core Loop

iOS:

1. Tap app icon or use shortcut widget
2. Land in last note, keyboard is down so you read first
3. Everything auto-saves, offline ok


## 3. Feature Set

`v0` aims for:

- File model
    - Notes are just `.md` files in a root folder
        - `iCloud Drive/lowercase`
        - `On My iPhone/lowercase`
    - subfolders for organization
        - `iCloud Drive/lowercase/daily`
        - `iCloud Drive/lowercase/projects`
- Editor
    - Plain text, monospaced, markdown-friendly
    - No line numbers
- Navigation
    - Home view with all subfolders/notes
    - Search by filename + content
    - Sort by:
        - Filename (a to z / a to a)
        - Modified (new to old / old to new)
        - Created (new to old / old to new)
- File naming
    - Default new note: `yyyy-mm-dd.md` or `untitled-1.md`
    - Titles lowercase by default; if user types uppercase, don't fight them in content, but UI chrome stays lowercase
- Sync
    - Use iCloud drive's documents folder, no custom infra
    - Everything offline first, iCloud sync as a bonus
    - Files you see in `Files` are the source of truth

No tags, backlinks, graph view in `v0`


## 4. Tech Stack Choice

Native Apple stack:

- Swift + SwiftUI
- Targets: `v1` iOS, later macOS (shared code, platform-specific tweaks)
- Storage
    - `FileManager` + iCloud ubiquity container
    - each note = `.md` file


## 5. Data Layer & Sync Model

We keep it dumb:

- Representation
    - Content lives in the file, not in memory-only state forever
- Loading notes
    - Read `.md` files lazily or on demand
- Sync
    - iCloud drive does its thing
    - No conflict resolution `v0`


## 6. Editor Design & Constraints

- Editor behavior
    - Auto-pair `() [] {} "" ''`
    - No auto-capitalize first letter of line
    - Auto-correction disabled


## 7. File Structure & Naming Conventions

- Root folder
    - `iCloud Drive/lowercase` or `On My iPhone/lowercase`
- Inside
    - Daily notes: `daily/yyyy-mm-dd.md`
- Titles
    - Renaming a note = renaming the file
    - Content never implicitly changes title names
    - Editable inline navigation title while in note editor


## 8. License, Pricing, Values

- One-time purchase
- Explicit promise:
    - "Notes are plain markdown files in your iCloud / device. You can open them with any editor, anytime. Lowercase will never lock you in."
- Open-source core


## 9. `v0` Non-Goals

- Tags 
- Backlinks
- Rich embeds