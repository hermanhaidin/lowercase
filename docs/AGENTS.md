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
- avoid UIKit unless requested
- no GCD
- modern Foundation APIs


## SwiftUI Correctness

- `foregroundStyle` over `foregroundColor`
- `NavigationStack` over `NavigationView`
- `@Observable` over `ObservableObject`
- `Button` over `onTapGesture`
- no `UIScreen.main.bounds`
- recursive `View` structs over recursive functions returning `some View` for tree UIs
- place view logic into view models or similar, so it can be tested
- no `AnyView` unless required

## Xcode Project Invariants

- the Xcode project must remain in the `lowercase/` folder
- do not move, rename, or recreate the `.xcodeproj` or `.xcworkspace`
- do not reorganize project folders unless explicitly requested
- treat the existing project structure as intentional