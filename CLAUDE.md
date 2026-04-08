# lowercase

A minimal markdown notes app for iPhone with a terminal/pixel aesthetic.
For people who think in files and folders — notes stored as plain `.md` files, no cloud lock-in.

- **Platform:** iOS 26+, iPhone only (iPad gets compatibility mode)
- **Language:** Swift 6.2, strict concurrency, MainActor default isolation
- **UI:** SwiftUI, dark mode only, portrait + landscape
- **Font:** Geist Pixel Square (single weight pixel font, 17pt body size)
- **Storage:** Plain `.md` files in the app's Documents directory (Files app accessible)
- **Architecture:** Feature-based folder structure, one type per file, `@Observable` for state

## Key conventions

- See `.claude/rules/app-overview.md` for product philosophy and scope
- See `.claude/rules/user-flow.md` for screens, navigation, and interactions
- See `.claude/rules/markdown-formatting.md` for editor syntax and shortcuts
- See `.claude/rules/coding-conventions.md` for coding rules
- Use `Design.*` constants for all colors, spacing, sizing
- Use `Font.geistPixel` for all text
- Use `Icon.*` enum for all icons
