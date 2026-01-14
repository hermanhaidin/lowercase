# Decisions

This document records significant product and technical decisions over time.


## 2026-01-03 — Filesystem-First Notes

App stores notes as plain `.md` files and treats the filesystem as the single source of truth.

- **Context**
    - I want to own my notes and be able to access them without a specific app
    - Markdown files are tiny, human-readable, and already well supported by iCloud
    - Complex infrastructure adds more cost than value
- **Why**
    - Users own their notes, not the app
    - iCloud's free tier is enough for syncing text files
    - No subscription or account required
- **Consequences**
    - Files in `Files.app` are the source of truth
    - Sync behavior depends on iCloud
    - Tags or backlinks become harder by design


## 2026-01-03 — Lowercase UI and Pixel Font

All UI copy is lowercase, paired with a pixel / bitmap-inspired monospace font.

- **Context**
    - Lowercase is faster — zero friction
    - Visually it feels softer / less shouty
    - Structure comes from spacing, bullets, hierarchy, not from grammar rules
- **Why**
    - Encourages speed over polish
    - Capitalization becomes intentional, not automatic
    - Matches the name and identity of the app
- **Consequences**
    - Accessibility and legibility require extra care


## 2026-01-03 — No Live Markdown Preview in `v0`

Lowercase `v0` does not include a live markdown preview.

- **Context**
    - Live preview shifts focus from writing to formatting
    - App aims to feel closer to a text editor or terminal than a document tool
- **Why**
    - Keeps the writing experience fast
    - Preserves the terminal-like, pixel-focused vibe
    - Avoids distancing the user from raw text while writing
- **Consequences**
    - Users must be comfortable with markdown syntax
    - UX must clearly support markdown conventions


## 2026-01-04 — Syntax-Aware Rendering Without Live Preview in `v1`

Lowercase may visually de-emphasize markdown syntax, but never replaces it with a rendered document view.

- **Context**
    - Raw markdown can be visually noisy while writing
    - Removing visual noise can improve focus and speed
    - Rendered documents (live preview / WYSIWYG) break the terminal-like feel
- **Allowed syntax-aware rendering `v1`**
    - Bold / emphasis
        - Markdown markers may be visually hidden when the cursor leaves the token
    - Inline links
        - Link syntax may be visually simplified when not focused
    - Checkboxes
        - Only the checkbox glyph is interactive
        - The label remains plain text
- **Why**
    - Reduces visual noise without changing the underlying file
    - Preserves fast, text-first writing
    - Keeps notes fully readable and editable in any other text editor
- **Consequences**
    - Markdown syntax must always remain intact in the file
    - No document-style rendering, layout, or block UI
    - Features that rely on hidden structure or metadata are out of scope


## 2026-01-04 — Folder-Based Organization Over Abstract Systems

Notes are organized using folders and filenames, not virtual groupings.

- **Context**
    - Files already have a hierarchy
    - Users understand folders across platforms
- **Why**
    - Structure remains visible outside the app
    - No parallel mental model to learn
- **Consequences**
    - Organization power is limited by filesystem
    - Search quality becomes critical

Advanced structure may exist only as conventions derived from text, not as a separate system.


## 2026-01-04 — No Subscriptions

Lowercase is a one-time purchase, not a subscription.

- **Context**
    - Notes are infrastructure, not a service
    - Markdown files do not require ongoing server costs
- **Why**
    - Aligns incentives with simplicity and stability
    - Removes pressure to add feature bloat
- **Consequences**
    - Revenue is front-loaded
    - Long-term sustainability depends on restraint, not churn


## 2026-01-04 — iOS-First Focus

Lowercase prioritizes iOS before macOS.

- **Context**
    - Primary use case is quick, lightweight note capture
    - Shared SwiftUI code makes later expansion feasible
- **Why**
    - Limits scope
    - Forces clarity in core interactions
- **Consequences**
    - macOS-specific workflows are postponed


## 2026-01-10 — System Monospaced Font Over Custom `MonacoTTF`

Lowercase uses the system font with monospaced design (via `.monospaced()` / monospaced font design) instead of the custom `MonacoTTF`.

- **Context**
    - `MonacoTTF` has readability issues at small sizes
    - Lack of clean bold/italic variants makes hierarchy harder
- **Why**
    - System font is more legible across dynamic type sizes
    - Bold/italic become available for hierarchy and emphasis
    - Keeps the UI consistent with platform typography conventions
- **Consequences**
    - Typography is controlled via SwiftUI modifiers (not a bundled font)
    - Visual identity comes from spacing, structure, and tone more than a custom typeface


## 2026-01-10 — List/Form First, With Small Consistent Adjustments

Lowercase prefers `List` and `Form` for most screens, with a small set of consistent tweaks (e.g. section spacing and bounce behavior).

- **Context**
    - Lists/forms are native, fast, and handle accessibility well
    - Custom scroll layouts require more code and tend to drift across screens
- **Why**
    - Consistency across screens with minimal styling surface
    - Better dynamic type behavior “for free”
    - Lower maintenance cost
- **Consequences**
    - We standardize a few defaults (e.g. `.listSectionSpacing(8)`, `.scrollBounceBehavior(.basedOnSize)`)
    - When we diverge, we do it intentionally and locally (not by introducing a large design system)


## 2026-01-10 — Primary Actions Use Full-Width Glass Prominent Buttons

Primary actions (especially in onboarding and creation flows) use a full-width “glass prominent” button style with bezel-aligned padding.

- **Context**
    - These flows have a single main action and should feel decisive
    - iOS 26’s glass styles look great and feel native
- **Why**
    - Clear hierarchy: one obvious primary action
    - Reduced layout variance across screens
- **Consequences**
    - We encapsulate the modifier combo to keep screens readable


## 2026-01-10 — Home Presents Folders as List Sections

Home displays folders as `List` sections (expand/collapse), with notes and nested folders shown as indented rows.

- **Context**
    - Hierarchy is the product (filesystem-first)
    - “Folders as sections” reads naturally and scales with content
- **Why**
    - Fast scanning: section headers anchor the hierarchy
    - Native list behavior + simple indentation yields clear structure
- **Consequences**
    - Home becomes a `List`-driven screen instead of a custom card layout