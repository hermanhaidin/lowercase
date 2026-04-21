import Foundation

enum HomeDestination: Hashable {
    case editor(url: URL, name: String, autoFocus: Bool)
}
