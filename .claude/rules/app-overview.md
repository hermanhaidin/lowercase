# App Overview

## What is lowercase?
A note-taking app that stores notes as plain `.md` files on your device. No cloud lock-in, no proprietary format. For people who think in files and folders.

Tagline: "Your thoughts are yours."

## Philosophy
- The app is a text editor. Storage and iCloud do their thing — the app stays out of the way.
- No forced auto-capitalization or grammar correction. Users write however they want.
- Users own their notes. Notes are plain text files accessible through Files app.
- Folder organization is complementary — the app's purpose is writing notes.

## Target & Business
- iPhone only, iOS 26+, paid app (~$10 USD one-time, no subscription)
- iPad gets compatibility mode (no iPad-specific layout)
- Dark mode only for terminal aesthetic

## Storage
- Two root destinations:
  - `iCloud Drive/lowercase/` (cloud-synced)
  - `On My iPhone/lowercase/` (local)
- Users switch between roots but never see both simultaneously
- iTunes file sharing enabled — "lowercase" directory visible in Files app
- Deleting notes/folders goes to Files/Recently Deleted when possible

## New Note Naming
- If parent folder name contains "daily" → note named `YYYY.MM.DD`
- Otherwise → `untitled-N` (incrementing)

## File Operations
- All operations scoped to current storage root
- Moving a folder into itself or its descendants is invalid
- No-op moves allowed (selecting current parent just dismisses)
- If a move happens while note is open, editor updates its URL — no recreating old file
- Same-name renames are no-ops

## Out of Scope (Post-Launch)
- Search, Settings view, Light mode
- In-app font size slider
- iPad / Mac native support
