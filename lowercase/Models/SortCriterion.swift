import Foundation

enum SortCriterion: String, CaseIterable, Identifiable {
    case name
    case modified
    case created

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .name: "Name"
        case .modified: "Modified"
        case .created: "Created"
        }
    }

    var defaultAscending: Bool {
        switch self {
        case .name: true
        case .modified: false
        case .created: false
        }
    }

    func directionLabel(ascending: Bool) -> String {
        switch self {
        case .name: ascending ? "a to z" : "z to a"
        case .modified: ascending ? "old to new" : "new to old"
        case .created: ascending ? "old to new" : "new to old"
        }
    }
}
