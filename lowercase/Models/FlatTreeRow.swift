import Foundation

struct FlatTreeRow: Identifiable, Equatable {
    let id: URL
    let name: String
    let isFolder: Bool
    let depth: Int
    let dateCreated: Date
    let dateModified: Date
    let hasChildren: Bool

    init(from node: FileNode, depth: Int) {
        self.id = node.id
        self.name = node.name
        self.isFolder = node.isFolder
        self.depth = depth
        self.dateCreated = node.dateCreated
        self.dateModified = node.dateModified
        self.hasChildren = !node.children.isEmpty
    }

    init(noteURL: URL, name: String) {
        self.id = noteURL
        self.name = name
        self.isFolder = false
        self.depth = 0
        self.dateCreated = .distantPast
        self.dateModified = .distantPast
        self.hasChildren = false
    }
}
