# lowercase

A minimal markdown notes app for iPhone with a terminal/pixel aesthetic.

- **Platform:** iOS 26+, iPhone only (iPad gets compatibility mode)
- **Language:** Swift 6.2, strict concurrency, MainActor default isolation
- **UI:** SwiftUI, dark mode only, portrait + landscape
- **Font:** Geist Pixel Square (single weight pixel font, 17pt body size)
- **Storage:** Plain `.md` files in the app's Documents directory (Files app accessible)
- **Architecture:** Feature-based folder structure, one type per file, `@Observable` for state

## Key conventions

- Use `Design.*` constants for all colors, spacing, sizing
- Use `Font.geistPixel` for all text
- Use `Icon.*` enum for all icons
- See `.claude/rules/coding-conventions.md` for detailed rules
