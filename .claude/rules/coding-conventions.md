# Coding Conventions

## Platform & Language
- iOS 26+, Swift 6.2, strict concurrency
- MainActor default isolation — no need for `MainActor.run()`
- `@Observable` + `@State` / `@Bindable` / `@Environment` (no legacy ObservableObject)
- `NavigationStack` with `navigationDestination(for:)` (no NavigationView)
- Dark mode only, portrait + landscape, iPhone only

## View Structure
- One type per file, extract subviews into separate View structs (no computed properties returning `some View`)
- Button actions extracted into separate methods
- Prefer `task()` over `onAppear()` for async work
- Use `ContentUnavailableView` for empty states
- `#Preview` for previews (no legacy PreviewProvider)

## Design System
- Use `Design.*` constants for all colors, spacing, sizing
- Use `Font.geistPixel` for all text — apply `.font(.geistPixel)` at the view level
- Use `Icon.*` enum for all icons
- `@ScaledMetric` or `relativeTo:` for any custom sizes
- Buttons must always include text labels (VoiceOver)
- Apple minimum tap area: 44x44

## Toolbar & Keyboard
- For bottom bars, use `safeAreaBar(edge: .bottom)` instead of `ToolbarItem(placement: .bottomBar)`
- For keyboard accessories, use `safeAreaInset(edge: .bottom)` instead of `ToolbarItem(placement: .keyboard)` — the latter offers no control over spacing, padding, or sizing
- When a `TextField` needs programmatic focus inside a `ToolbarItem`, use a `UIViewRepresentable` wrapping `UITextField` with `becomeFirstResponder()` — `@FocusState` is broken in toolbar placements (unfixed through iOS 26)
- Custom back button icon is set globally via `UINavigationBar.appearance().backIndicatorImage` in the App `init()` — never hide the system back button to replace it with a custom one, as this breaks the native swipe-back gesture and Liquid Glass styling
- All confirmations use sheets, not `confirmationDialog()`

## File System
- Treat file `URL` as the source of truth for file identity — models hold `URL`, not `String` paths
- Prefer modern Foundation API: `URL.documentsDirectory` over `FileManager` directory lookups, `appending(path:)` over `appendingPathComponent(_:)`
- Prefer URL-based APIs: `contentsOfDirectory(at:)` over `contentsOfDirectory(atPath:)`, `removeItem(at:)` over `removeItem(atPath:)`, `moveItem(at:to:)` over `moveItem(atPath:toPath:)`
- Use `resourceValues(forKeys:)` for file attributes instead of `attributesOfItem(atPath:)`
- When writing data, use `write(to:options:)` with `[.atomic, .completeFileProtection]`
- When deleting, prefer `trashItem(at:resultingItemURL:)` over `removeItem(at:)` for user-initiated deletes

## Swift Style
- Prefer `if let value {` shorthand
- Omit return for single expression functions
- Use `async`/`await` (no GCD)
- Prefer `Double` over `CGFloat`
- `localizedStandardContains()` for user-input text filtering
