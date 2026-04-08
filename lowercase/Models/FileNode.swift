import Foundation

struct FileNode: Identifiable, Hashable {
    let id: URL
    let name: String
    let isFolder: Bool
    let dateCreated: Date
    let dateModified: Date
    var children: [FileNode]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FileNode, rhs: FileNode) -> Bool {
        lhs.id == rhs.id
    }
}
