import Foundation

struct FlatTreeRow: Identifiable {
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
}
