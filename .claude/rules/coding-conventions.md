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
- When a `TextField` needs programmatic focus inside a `ToolbarItem`, use a `UIViewRepresentable` wrapping `UITextField` — `@FocusState` is broken in toolbar placements (unfixed through iOS 26). Key requirements for toolbar `UIViewRepresentable`:
  - Keep it always present and toggle `isUserInteractionEnabled` — never conditionally swap between `Text` and a `UIViewRepresentable`, as SwiftUI animates the swap with a layout bounce from (0,0)
  - Subclass `UITextField` to override `intrinsicContentSize` based on actual text width — without this the field gets an incorrect frame
  - Apply `.id(verticalSizeClass)` so the view is recreated with a fresh layout on rotation — SwiftUI caches the hosting-view frame from the initial toolbar layout
  - Manage focus via a `@Binding var isFocused: Bool` with a cancellable `Task` in the coordinator, not `DispatchQueue.main.async`
- Custom back button icon is set globally via `UINavigationBar.appearance().backIndicatorImage` in the App `init()` — never hide the system back button to replace it with a custom one, as this breaks the native swipe-back gesture and Liquid Glass styling
- For custom inline title text, use `ToolbarItem(placement: .title)` paired with `.toolbarTitleDisplayMode(.inline)`
- Views with keyboards must use `.background(Design.Colors.background.ignoresSafeArea())` — the shorthand `ShapeStyle` variant extends the background behind the keyboard without disrupting `safeAreaBar` layout, preventing the black window background from showing through the keyboard's rounded corners
- All confirmations use sheets, not `confirmationDialog()`
- For content-fitted sheets, use `FittedPresentationModifier` — it measures content height via `onGeometryChange` and applies a matching `.height()` detent. Sheet content must not use `maxHeight: .infinity` in its frame, or the measurement will be defeated.

## File System
- Treat file `URL` as the source of truth for file identity — models hold `URL`, not `String` paths
- Prefer modern Foundation API: `URL.documentsDirectory` over `FileManager` directory lookups, `appending(path:)` over `appendingPathComponent(_:)`
- Prefer URL-based APIs: `contentsOfDirectory(at:)` over `contentsOfDirectory(atPath:)`, `removeItem(at:)` over `removeItem(atPath:)`, `moveItem(at:to:)` over `moveItem(atPath:toPath:)`
- Use `resourceValues(forKeys:)` for file attributes instead of `attributesOfItem(atPath:)`
- When writing data, use `write(to:options:)` with `[.atomic, .completeFileProtection]`
- When deleting, prefer `trashItem(at:resultingItemURL:)` over `removeItem(at:)` for user-initiated deletes

## Gestures
- `.onLongPressGesture` on a `Button` is swallowed by the button's tap recognizer — use `.simultaneousGesture(LongPressGesture().onEnded { })` instead
- Plain `var` properties on child views may not trigger re-evaluation of `LazyVStack` content — use `@Binding` to create a proper reactive dependency when the parent's state needs to drive conditional rendering inside a lazy container

## Swift Style
- Prefer `if let value {` shorthand
- Omit return for single expression functions
- Use `async`/`await` (no GCD)
- Prefer `Double` over `CGFloat`
- `localizedStandardContains()` for user-input text filtering
