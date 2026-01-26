# Agent Rules — iOS / Swift / SwiftUI

These rules define **mandatory technical constraints** for agents working on this repository.

They exist to:
- target modern Apple platforms correctly
- avoid deprecated or legacy APIs
- maintain consistency with current SwiftUI best practices

If a suggestion violates these rules, do not propose it.


## Platform & Modernity

- iOS 26+ target
- Swift 6.2+
- modern Swift concurrency (async/await, Task, actors)
- use modern Foundation URL APIs (e.g. `URL.documentsDirectory`, `appending(path:)`) for path construction and clarity
- avoid UIKit unless requested
- no GCD
- modern Foundation APIs


## SwiftUI Correctness

- filter text-based user input using `localizedStandardContains()`
- `foregroundStyle` over `foregroundColor`
- `clipShape(.rect(cornerRadius:))` over `cornerRadius()`
- `NavigationStack` over `NavigationView`
- use a single typed route enum + `NavigationPath` for pushes; prefer `navigationDestination(for:)` + `NavigationLink(value:)`
- avoid nested `NavigationStack` inside views that are pushed onto an existing stack
- preserve the system back swipe gesture
- `@Observable` over `ObservableObject`
- `Button` over `onTapGesture`
- `Task.sleep(for:)` over `Task.sleep(nanoseconds:)`
- no `UIScreen.main.bounds`
- `View` structs over computed properties
- `View` structs over functions returning `some View`
- `Dynamic Type` over specific font sizes
- place view logic into view models or similar, so it can be tested
- no `AnyView` unless required
- when hiding scroll view indicators, use the `scrollIndicators(.hidden)`

## SwiftUI / UIKit Exception

- Prefer SwiftUI APIs, but using UIKit keyboard notifications is allowed to obtain accurate keyboard height for scroll + padding behavior

## Xcode Project Invariants

- the Xcode project must remain in the `lowercase/` folder
- do not move, rename, or recreate the `.xcodeproj` or `.xcworkspace`
- do not reorganize project folders unless explicitly requested
- treat the existing project structure as intentional