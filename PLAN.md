# Phase 0: Project Scaffold Plan

## Context

The repo has a bare Xcode project (iOS 26.4, Swift 6.2, MainActor default isolation) with just the default template files. Before any feature work begins, we need a proper scaffold: `.gitignore`, project rules, font/icon asset pipeline, design tokens, folder structure, and correct build settings. This ensures every future phase builds on solid foundations rather than retrofitting infrastructure.

---

## Step 1: `.gitignore`

Create a standard iOS/Xcode `.gitignore` at repo root covering:
- `.DS_Store`, `xcuserdata/`, `DerivedData/`, `*.xcuserstate`
- Build artifacts, `*.ipa`, `*.dSYM.zip`
- CocoaPods/SPM build cache (future-proofing)

**File:** `/lowercase/.gitignore` (repo root)

---

## Step 2: Xcode Build Settings Fixes

Verify `lowercase.xcodeproj/project.pbxproj` — both Debug and Release target configs:

| Setting | Value |
|---------|-------|
| `TARGETED_DEVICE_FAMILY` | `1` (iPhone only — iPad users get compatibility mode; flip back to `"1,2"` post-v1) |
| `SWIFT_VERSION` | `6.0` |
| `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad` | (removed) |
| `INFOPLIST_KEY_UIUserInterfaceStyle` | `Dark` |
| `UIAppFonts` | `GeistPixel-Square.otf` (registers font with system) |
| `UIFileSharingEnabled` | `YES` (exposes documents in iTunes/Finder) |
| `LSSupportsOpeningDocumentsInPlace` | `YES` (enables Files app access to notes) |

**Orientation:** Keep portrait + landscape as-is (no lock).

All settings are configured via Xcode's target Info tab / Build Settings — no physical `Info.plist` file needed (`GENERATE_INFOPLIST_FILE` stays `YES`).

---

## Step 3: Font Bundling (Geist Pixel Square)

**Source:** [vercel/geist-pixel-font](https://github.com/vercel/geist-pixel-font) releases

1. Verify `lowercase/Resources/Fonts/GeistPixel-Square.otf` exists
2. Verify `lowercase/Resources/Fonts/OFL.txt` (SIL Open Font License) exists
3. Verify `UIAppFonts` is registered in build settings (Step 2)
4. Create `lowercase/Theme/Font+Theme.swift` — a `Font` extension:

```swift
import SwiftUI

extension Font {
    /// Geist Pixel Square at body size, scaled for Dynamic Type.
    static let geistPixel = Font.custom(
        "GeistPixel-Square",
        size: 17,
        relativeTo: .body
    )
}
```

- `relativeTo: .body` ensures Dynamic Type scaling (per swiftui-pro accessibility rules)
- Apply `.font(.geistPixel)` at the view level so it propagates to all children including `TextField`

---

## Step 4: Geist Icons

**Approach:** Export SVGs from Figma as needed, add to Asset Catalog.

1. Verify `lowercase/Assets.xcassets/Icons/` contains 34 SVG image sets (Preserve Vector Data, Single Scale, Render As Template)
3. Create `lowercase/Theme/Icon.swift` — a typed enum for icon names:

```swift
import SwiftUI

enum Icon: String {
    // Navigation
    case arrowLeft = "arrow-left"
    case chevronRight = "chevron-right"
    case chevronDown = "chevron-down"
    case chevronUpDown = "chevron-up-down"

    // Files & Folders
    case fileText = "file-text"
    case folderClosed = "folder-closed"
    case folderOpen = "folder-open"
    case folderDependent = "folder-dependent"
    case repositories

    // Actions
    case plus
    case plusCircle = "plus-circle"
    case cross
    case check
    case trash
    case pencilEdit = "pencil-edit"
    case share

    // Text Formatting
    case textBold = "text-bold"
    case textItalic = "text-italic"
    case textStrikethrough = "text-strikethrough"
    case textHeading = "text-heading"
    case link
    case codeWrap = "code-wrap"
    case slash

    // Lists
    case listOrdered = "list-ordered"
    case listUnordered = "list-unordered"
    case listNestLeft = "list-nest-left"
    case listNestRight = "list-nest-right"

    // History
    case cornerUpLeft = "corner-up-left"
    case cornerUpRight = "corner-up-right"

    // Misc
    case arrowUpDown = "arrow-up-down"
    case moreHorizontal = "more-horizontal"
    case cloud
    case devicePhone = "device-phone"
    case faceUnhappy = "face-unhappy"

    var image: Image {
        Image(rawValue)
    }
}
```

This gives type-safe access (`Icon.folderOpen.image`) while keeping SVGs in the asset catalog. Raw values match the asset catalog names exactly.

---

## Step 5: Design Tokens (Theme Constants)

Create `lowercase/Theme/Design.swift` — shared constants enum per swiftui-pro design reference:

```swift
import SwiftUI

enum Design {
    // MARK: - Colors
    enum Colors {
        // Backgrounds
        static let background = Color(hex: 0x151515)
        static let secondaryBackground = Color(hex: 0x222222)

        // Labels
        static let label = Color.white
        static let secondaryLabel = Color(hex: 0xA6A6A6)
        static let tertiaryLabel = Color(hex: 0x585858)

        // Accents
        static let accent = Color(hex: 0xBF98AB)            // rose — headings, markers, cursor
        static let secondaryAccent = Color(hex: 0xE6DEC2)   // cream — bold text, folder icons
        static let tertiaryAccent = Color(hex: 0x70A6AD)    // teal — italic, links, toggle ON

        // System
        static let separator = Color(hex: 0x373636)
        static let glassTint = Color(hex: 0x9F7C8F)         // primary CTA tint
    }

    // MARK: - Spacing
    enum Spacing {
        static let contentMargin: Double = 20   // horizontal margin for tree view, editor
        static let buttonMargin: Double = 36    // horizontal margin for bottom CTA buttons
        static let labelGap: Double = 12         // icon-to-label gap (tree rows, sheet rows, pickers)
        static let treeIndent: Double = 16
        static let iconGap: Double = 8           // gap between adjacent icons (e.g. chevron + folder)
    }

    // MARK: - Sizing
    enum Sizing {
        static let minRowHeight: Double = 44     // use .frame(minHeight:), grows with Dynamic Type
        static let iconSize: Double = 16
        static let toolbarItemSize: Double = 44
    }
}
```

Also create `lowercase/Theme/Color+Hex.swift` for the hex initializer utility.

---

## Step 6: Folder Structure

Create the feature-based directory layout (one type per file, per swiftui-pro views reference):

```
lowercase/
├── lowercaseApp.swift
├── Features/
│   ├── Onboarding/                 (empty, ready for Phase 1)
│   ├── Home/                       (empty, ready for Phase 2)
│   ├── Editor/                     (empty, ready for Phase 3)
│   └── Shared/                     (destination picker, sheets)
├── Models/                         (empty, ready for data types)
├── Services/                       (empty, ready for FileService)
├── Theme/
│   ├── Design.swift
│   ├── Font+Theme.swift
│   ├── Color+Hex.swift
│   └── Icon.swift
├── Resources/
│   └── Fonts/
│       ├── GeistPixel-Square.otf
│       └── OFL.txt
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   ├── AccentColor.colorset/
│   ├── Icons/                      (Geist SVG icon sets)
│   └── Contents.json
└── ContentView.swift               (temporary, replaced in Phase 1)
```

The project uses `PBXFileSystemSynchronizedRootGroup`, so Xcode auto-discovers any files placed inside `lowercase/`. No pbxproj edits needed for adding files — just create the folders and files on disk.

---

## Step 7: Project Rules

### `CLAUDE.md` (repo root) — high-level project identity

Brief description of the app, target platform, key architectural decisions, and pointers to detailed rules.

### `.claude/rules/coding-conventions.md` — detailed coding rules

Extracted from swiftui-pro references, tailored to this project:
- iOS 26+, Swift 6.2, strict concurrency, MainActor default isolation
- `@Observable` + `@State` / `@Bindable` / `@Environment` (no legacy ObservableObject)
- `NavigationStack` with `navigationDestination(for:)` (no NavigationView)
- One type per file, extract subviews into separate View structs (no computed properties returning `some View`)
- Use `Design.*` constants for all colors, spacing, sizing
- Use `Font.geistPixel` for all text
- Use `Icon.*` enum for all icons
- Dark mode only, portrait + landscape, iPhone only
- `confirmationDialog()` attached to trigger source (Liquid Glass animation)
- Button actions extracted into separate methods
- Prefer `task()` over `onAppear()` for async work
- `@ScaledMetric` or `relativeTo:` for any custom sizes
- Buttons must always include text labels (VoiceOver)
- Use `ContentUnavailableView` for empty states
- For bottom bars, use `safeAreaBar(edge: .bottom)` instead of `ToolbarItem(placement: .bottomBar)`
- For keyboard accessories, use `safeAreaInset(edge: .bottom)` instead of `ToolbarItem(placement: .keyboard)` — the latter offers no control over spacing, padding, or sizing
- When a `TextField` needs programmatic focus inside a `ToolbarItem`, use a `UIViewRepresentable` wrapping `UITextField` with `becomeFirstResponder()` — `@FocusState` is broken in toolbar placements (unfixed through iOS 26)

File System:
- Treat file `URL` as the source of truth for file identity — models hold `URL`, not `String` paths
- Prefer modern Foundation API: `URL.documentsDirectory` over `FileManager` directory lookups, `appending(path:)` over `appendingPathComponent(_:)`
- Prefer URL-based APIs: `contentsOfDirectory(at:)` over `contentsOfDirectory(atPath:)`, `removeItem(at:)` over `removeItem(atPath:)`, `moveItem(at:to:)` over `moveItem(atPath:toPath:)`
- Use `resourceValues(forKeys:)` for file attributes instead of `attributesOfItem(atPath:)`
- When writing data, use `write(to:options:)` with `[.atomic, .completeFileProtection]`
- When deleting, prefer `trashItem(at:resultingItemURL:)` over `removeItem(at:)` for user-initiated deletes

---

## Step 8: Remove Stale Template Code

- Delete `ContentView.swift` boilerplate content (replace with minimal placeholder that shows "lowercase" text using Geist Pixel font — serves as font integration test)
- Clean up `lowercaseApp.swift` (remove template header comment, apply project conventions)

---

## Verification

1. **Build test:** Open in Xcode, build for iPhone simulator — should compile with zero warnings
2. **Font test:** The placeholder ContentView should render "lowercase" in Geist Pixel Square
3. **Git:** `git status` should show clean tracking (no xcuserdata, no DerivedData, no .DS_Store)
4. **Build settings:** Verify in Xcode target Info tab that File Sharing, Open In Place, Font, and Dark Mode are set correctly
5. **Settings:** Confirm iPhone-only target, portrait + landscape orientation in Xcode General tab

---

## What Phase 0 Does NOT Include

- No feature code (onboarding, home, editor — those are Phase 1+)
- No navigation structure yet
- No file system service implementation
- No iCloud container setup (needs Apple Developer portal config first)
- No app icon design

---

## Dependencies / User Actions Required

1. **Font file:** Done — `GeistPixel-Square.otf` and `OFL.txt` in `lowercase/Resources/Fonts/`
2. **Icons:** Done — 34 SVGs exported from Figma into `Assets.xcassets/Icons/` as image sets
3. **Build settings:** Done — all target settings configured manually in Xcode (Step 2)
4. **Apple Developer:** iCloud container entitlement setup (deferred to when iCloud storage feature is built)
