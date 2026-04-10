import Foundation

@Observable
final class FileStore {

    // MARK: - State

    var activeRoot: StorageRoot
    private(set) var rootChildren: [FileNode] = []
    var sortOrder = SortOrder()
    var expandedFolders: Set<URL> = []
    var currentError: FileError?

    private static let activeRootKey = "activeRoot"

    // MARK: - Derived

    var flatRows: [FlatTreeRow] {
        flattenTree(rootChildren, depth: 0)
    }

    var isEmpty: Bool { rootChildren.isEmpty }

    var allExpanded: Bool {
        let allFolderURLs = collectAllFolderURLs(from: rootChildren)
        return !allFolderURLs.isEmpty && allFolderURLs.isSubset(of: expandedFolders)
    }

    // MARK: - Internal

    let iCloudMonitor = ICloudMonitor()
    private let fileManager = FileManager.default
    private var iCloudContainerURL: URL?

    // MARK: - Init

    init() {
        if let saved = UserDefaults.standard.string(forKey: Self.activeRootKey),
           let root = StorageRoot(rawValue: saved) {
            activeRoot = root
        } else {
            activeRoot = .local
        }

        iCloudMonitor.onUpdate = { [weak self] in
            try? await self?.loadTree()
        }

        if activeRoot == .iCloud {
            iCloudMonitor.startMonitoring()
        }
    }

    // MARK: - Root URL

    var localRootURL: URL { URL.documentsDirectory }

    func resolveRootURL() async -> URL? {
        switch activeRoot {
        case .local:
            localRootURL
        case .iCloud:
            await resolveICloudURL()
        }
    }

    private func resolveICloudURL() async -> URL? {
        if let cached = iCloudContainerURL { return cached }
        let url = await Task.detached {
            FileManager.default.url(forUbiquityContainerIdentifier: nil)
        }.value
        iCloudContainerURL = url?.appending(path: "Documents")
        return iCloudContainerURL
    }

    // MARK: - Tree Loading

    func loadTree() async throws {
        guard let root = await resolveRootURL() else {
            rootChildren = []
            throw FileError.rootUnavailable
        }

        ensureDirectoryExists(at: root)

        do {
            rootChildren = try await scanDirectory(at: root)
        } catch {
            rootChildren = []
            throw error
        }
    }

    private func scanDirectory(at url: URL) async throws -> [FileNode] {
        let contents: [URL]
        if activeRoot == .iCloud {
            contents = try await coordinatedDirectoryContents(at: url)
        } else {
            contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .creationDateKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
        }

        var nodes: [FileNode] = []

        for itemURL in contents {
            let values = try itemURL.resourceValues(
                forKeys: [.isDirectoryKey, .creationDateKey, .contentModificationDateKey]
            )

            let isDir = values.isDirectory ?? false

            // Skip non-.md files that aren't directories
            if !isDir && itemURL.pathExtension != "md" { continue }

            let children = isDir ? try await scanDirectory(at: itemURL) : []

            let node = FileNode(
                id: itemURL,
                name: isDir
                    ? itemURL.lastPathComponent
                    : itemURL.deletingPathExtension().lastPathComponent,
                isFolder: isDir,
                dateCreated: values.creationDate ?? .distantPast,
                dateModified: values.contentModificationDate ?? .distantPast,
                children: children
            )
            nodes.append(node)
        }

        return sortNodes(nodes)
    }

    // MARK: - Sorting

    private func sortNodes(_ nodes: [FileNode]) -> [FileNode] {
        let folders = sortItems(nodes.filter(\.isFolder))
        let notes = sortItems(nodes.filter { !$0.isFolder })
        return folders + notes
    }

    private func sortItems(_ items: [FileNode]) -> [FileNode] {
        items.sorted { a, b in
            let result: Bool
            switch sortOrder.criterion {
            case .name:
                result = a.name.localizedStandardCompare(b.name) == .orderedAscending
            case .modified:
                result = a.dateModified < b.dateModified
            case .created:
                result = a.dateCreated < b.dateCreated
            }
            return sortOrder.ascending ? result : !result
        }
    }

    func resort() {
        rootChildren = resortTree(rootChildren)
    }

    private func resortTree(_ nodes: [FileNode]) -> [FileNode] {
        sortNodes(nodes.map { node in
            var copy = node
            if node.isFolder {
                copy.children = resortTree(node.children)
            }
            return copy
        })
    }

    // MARK: - Flattening

    private func flattenTree(_ nodes: [FileNode], depth: Int) -> [FlatTreeRow] {
        var rows: [FlatTreeRow] = []
        let folders = nodes.filter(\.isFolder)
        let notes = nodes.filter { !$0.isFolder }

        for folder in folders {
            rows.append(FlatTreeRow(from: folder, depth: depth))
            if expandedFolders.contains(folder.id) {
                rows += flattenTree(folder.children, depth: depth + 1)
            }
        }

        for note in notes {
            rows.append(FlatTreeRow(from: note, depth: depth))
        }

        return rows
    }

    // MARK: - Expansion

    func toggleExpansion(for folderURL: URL) {
        if expandedFolders.contains(folderURL) {
            expandedFolders.remove(folderURL)
        } else {
            expandedFolders.insert(folderURL)
        }
    }

    func expandAll() {
        expandedFolders = collectAllFolderURLs(from: rootChildren)
    }

    func collapseAll() {
        expandedFolders.removeAll()
    }

    private func collectAllFolderURLs(from nodes: [FileNode]) -> Set<URL> {
        var urls = Set<URL>()
        for node in nodes where node.isFolder {
            urls.insert(node.id)
            urls.formUnion(collectAllFolderURLs(from: node.children))
        }
        return urls
    }

    // MARK: - Create Note

    /// Creates a new note in the specified folder (or root if nil).
    /// For daily folders, returns the existing daily note URL if one exists for today.
    @discardableResult
    func createNote(in folderURL: URL? = nil) async throws -> URL {
        guard let root = await resolveRootURL() else {
            throw FileError.rootUnavailable
        }

        let parent = folderURL ?? root
        ensureDirectoryExists(at: parent)

        // For daily folders, return existing note if today's already exists
        let folderName = parent.lastPathComponent.lowercased()
        if folderName.contains("daily"), let existing = NoteNamer.dailyNoteExists(in: parent) {
            return existing
        }

        let name = NoteNamer.nextName(in: parent)
        let noteURL = parent.appending(path: "\(name).md")

        let data = Data()
        try await coordinatedWrite(data: data, to: noteURL)

        try await loadTree()
        return noteURL
    }

    // MARK: - Create Folder

    /// Creates a folder. Supports slash syntax for nesting ("daily/work").
    @discardableResult
    func createFolder(named name: String, in parentURL: URL? = nil) async throws -> URL {
        guard let root = await resolveRootURL() else {
            throw FileError.rootUnavailable
        }

        let parent = parentURL ?? root
        let folderURL = parent.appending(path: name)

        if fileManager.fileExists(atPath: folderURL.path(percentEncoded: false)) {
            throw FileError.alreadyExists(name)
        }

        try fileManager.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true
        )

        try await loadTree()
        return folderURL
    }

    // MARK: - Read Note

    func readNote(at url: URL) async throws -> String {
        let data = try await coordinatedRead(at: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw FileError.readFailed(url, underlying: CocoaError(.fileReadInapplicableStringEncoding))
        }
        return content
    }

    // MARK: - Write Note

    func writeNote(_ content: String, to url: URL) async throws {
        guard let data = content.data(using: .utf8) else {
            throw FileError.writeFailed(
                url,
                underlying: CocoaError(.fileWriteInapplicableStringEncoding)
            )
        }
        try await coordinatedWrite(data: data, to: url)
    }

    // MARK: - Trash

    func trashItem(at url: URL) async throws {
        try await coordinatedDelete(at: url)
        try await loadTree()
    }

    // MARK: - Rename

    /// Renames an item. No-op if the new name matches the current name.
    @discardableResult
    func rename(at url: URL, to newName: String) async throws -> URL {
        let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
        let currentName = isDir
            ? url.lastPathComponent
            : url.deletingPathExtension().lastPathComponent

        guard newName != currentName else { return url }

        let ext = isDir ? "" : ".md"
        let newURL = url.deletingLastPathComponent().appending(path: "\(newName)\(ext)")

        if fileManager.fileExists(atPath: newURL.path(percentEncoded: false)) {
            throw FileError.alreadyExists(newName)
        }

        try await coordinatedMove(from: url, to: newURL)
        try await loadTree()

        // Update expanded folders set if a folder was renamed
        if isDir && expandedFolders.contains(url) {
            expandedFolders.remove(url)
            expandedFolders.insert(newURL)
        }

        return newURL
    }

    // MARK: - Move

    /// Moves an item to a new parent folder. No-op if already in that folder.
    @discardableResult
    func moveItem(at url: URL, to destinationFolder: URL) async throws -> URL {
        let currentParent = url.deletingLastPathComponent()
        guard destinationFolder != currentParent else { return url }

        // Prevent moving a folder into itself or its descendants
        let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
        if isDir {
            let srcPath = url.path(percentEncoded: false)
            let dstPath = destinationFolder.path(percentEncoded: false)
            if dstPath.hasPrefix(srcPath) {
                throw FileError.invalidMove("Cannot move a folder into itself or its subfolder.")
            }
        }

        let newURL = destinationFolder.appending(path: url.lastPathComponent)

        if fileManager.fileExists(atPath: newURL.path(percentEncoded: false)) {
            throw FileError.alreadyExists(url.lastPathComponent)
        }

        ensureDirectoryExists(at: destinationFolder)
        try await coordinatedMove(from: url, to: newURL)
        try await loadTree()
        return newURL
    }

    // MARK: - Switch Root

    func switchRoot(to root: StorageRoot) async throws {
        activeRoot = root
        UserDefaults.standard.set(root.rawValue, forKey: Self.activeRootKey)
        expandedFolders.removeAll()
        rootChildren = []

        if root == .iCloud {
            iCloudMonitor.startMonitoring()
        } else {
            iCloudMonitor.stopMonitoring()
        }

        try await loadTree()
    }

    // MARK: - Folder List for Destination Pickers

    /// Returns all folders with depth info. Pass `excluding` to filter out a folder and its descendants (for move operations).
    func allFolders(excluding: URL? = nil) -> [(url: URL, name: String, depth: Int)] {
        collectFolders(from: rootChildren, depth: 0, excluding: excluding)
    }

    private func collectFolders(
        from nodes: [FileNode],
        depth: Int,
        excluding: URL?
    ) -> [(url: URL, name: String, depth: Int)] {
        var result: [(url: URL, name: String, depth: Int)] = []
        for node in nodes where node.isFolder {
            // Skip excluded folder and all its descendants
            if let excluding,
               node.id.path(percentEncoded: false)
                   .hasPrefix(excluding.path(percentEncoded: false)) {
                continue
            }
            result.append((url: node.id, name: node.name, depth: depth))
            result += collectFolders(from: node.children, depth: depth + 1, excluding: excluding)
        }
        return result
    }

    // MARK: - File Coordination

    private func coordinatedRead(at url: URL) async throws -> Data {
        try await Task.detached {
            var coordinatorError: NSError?
            var readData: Data?
            var readError: (any Error)?

            let coordinator = NSFileCoordinator()
            coordinator.coordinate(
                readingItemAt: url,
                options: [],
                error: &coordinatorError
            ) { coordinatedURL in
                do {
                    readData = try Data(contentsOf: coordinatedURL)
                } catch {
                    readError = error
                }
            }

            if let coordinatorError { throw coordinatorError }
            if let readError { throw readError }
            return readData ?? Data()
        }.value
    }

    private func coordinatedWrite(data: Data, to url: URL) async throws {
        try await Task.detached {
            var coordinatorError: NSError?
            var writeError: (any Error)?

            let coordinator = NSFileCoordinator()
            coordinator.coordinate(
                writingItemAt: url,
                options: .forReplacing,
                error: &coordinatorError
            ) { coordinatedURL in
                do {
                    try data.write(
                        to: coordinatedURL,
                        options: [.atomic, .completeFileProtection]
                    )
                } catch {
                    writeError = error
                }
            }

            if let coordinatorError { throw coordinatorError }
            if let writeError { throw writeError }
        }.value
    }

    private func coordinatedDelete(at url: URL) async throws {
        try await Task.detached {
            var coordinatorError: NSError?
            var deleteError: (any Error)?

            let coordinator = NSFileCoordinator()
            coordinator.coordinate(
                writingItemAt: url,
                options: .forDeleting,
                error: &coordinatorError
            ) { coordinatedURL in
                do {
                    try FileManager.default.trashItem(
                        at: coordinatedURL,
                        resultingItemURL: nil
                    )
                } catch {
                    // Fallback to permanent delete if trash is unavailable
                    do {
                        try FileManager.default.removeItem(at: coordinatedURL)
                    } catch {
                        deleteError = error
                    }
                }
            }

            if let coordinatorError { throw coordinatorError }
            if let deleteError { throw deleteError }
        }.value
    }

    private func coordinatedMove(from sourceURL: URL, to destinationURL: URL) async throws {
        try await Task.detached {
            var coordinatorError: NSError?
            var moveError: (any Error)?

            let coordinator = NSFileCoordinator()
            coordinator.coordinate(
                writingItemAt: sourceURL,
                options: .forMoving,
                writingItemAt: destinationURL,
                options: .forReplacing,
                error: &coordinatorError
            ) { coordSource, coordDest in
                do {
                    try FileManager.default.moveItem(at: coordSource, to: coordDest)
                } catch {
                    moveError = error
                }
            }

            if let coordinatorError { throw coordinatorError }
            if let moveError { throw moveError }
        }.value
    }

    private func coordinatedDirectoryContents(at url: URL) async throws -> [URL] {
        try await Task.detached {
            var coordinatorError: NSError?
            var contents: [URL] = []
            var readError: (any Error)?

            let coordinator = NSFileCoordinator()
            coordinator.coordinate(
                readingItemAt: url,
                options: [],
                error: &coordinatorError
            ) { coordinatedURL in
                do {
                    contents = try FileManager.default.contentsOfDirectory(
                        at: coordinatedURL,
                        includingPropertiesForKeys: [
                            .isDirectoryKey, .creationDateKey, .contentModificationDateKey
                        ],
                        options: [.skipsHiddenFiles]
                    )
                } catch {
                    readError = error
                }
            }

            if let coordinatorError { throw coordinatorError }
            if let readError { throw readError }
            return contents
        }.value
    }

    // MARK: - Helpers

    private func ensureDirectoryExists(at url: URL) {
        if !fileManager.fileExists(atPath: url.path(percentEncoded: false)) {
            try? fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }
    }
}
