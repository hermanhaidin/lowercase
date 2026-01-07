//
//  FileStore.swift
//  lowercase
//

import Foundation

/// Manages file system operations for notes and folders.
@Observable
final class FileStore {
    
    // MARK: - Properties
    
    /// Current storage root (local or iCloud)
    var currentRoot: StorageRoot = .local
    
    /// Cached folders for current root
    private(set) var folders: [Folder] = []
    
    /// Notes in root directory (not in any folder)
    private(set) var orphanNotes: [Note] = []
    
    /// File manager instance
    private let fileManager = FileManager.default
    
    // MARK: - Computed Properties
    
    /// Base URL for current storage root
    var rootURL: URL? {
        currentRoot.baseURL(
            localDocuments: documentsDirectory,
            icloudContainer: icloudContainerURL
        )
    }
    
    /// Local documents directory
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// iCloud ubiquity container (nil if not available)
    private var icloudContainerURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: nil)
    }
    
    /// Total folder count
    var folderCount: Int {
        folders.reduce(0) { $0 + 1 + $1.subfolders.count }
    }
    
    /// Total note count (including orphans)
    var noteCount: Int {
        folders.reduce(0) { $0 + $1.totalNoteCount } + orphanNotes.count
    }
    
    // MARK: - Init
    
    init() {
        // Ensure root directory exists
        ensureRootDirectoryExists()
    }
    
    // MARK: - Directory Setup
    
    /// Creates root directory if it doesn't exist
    private func ensureRootDirectoryExists() {
        guard let rootURL else { return }
        
        if !fileManager.fileExists(atPath: rootURL.path) {
            try? fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        }
    }
    
    /// Check if any folders exist in current root
    var hasAnyFolders: Bool {
        guard let rootURL else { return false }
        
        let contents = (try? fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        
        return contents.contains { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
        }
    }
    
    /// Check if any content (folders or notes) exists in current root
    var hasAnyContent: Bool {
        guard let rootURL else { return false }
        
        let contents = (try? fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        
        // Has folders OR has .md files
        return contents.contains { url in
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
            let isMarkdown = url.pathExtension.lowercased() == "md"
            return isDirectory || isMarkdown
        }
    }
    
    /// Whether to show onboarding (no content exists)
    var shouldShowOnboarding: Bool {
        !hasAnyContent
    }
    
    // MARK: - Load Data
    
    /// Reload all folders and notes from disk
    func reload() {
        guard let rootURL else {
            folders = []
            orphanNotes = []
            return
        }
        
        folders = loadFolders(at: rootURL, depth: 0)
        orphanNotes = loadNotes(at: rootURL, isOrphan: true)
    }
    
    /// Load folders at a given URL
    private func loadFolders(at url: URL, depth: Int) -> [Folder] {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        
        return contents.compactMap { itemURL -> Folder? in
            guard let resourceValues = try? itemURL.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey, .creationDateKey]),
                  resourceValues.isDirectory == true else {
                return nil
            }
            
            let notes = loadNotes(at: itemURL, isOrphan: false)
            let subfolders = loadFolders(at: itemURL, depth: depth + 1)
            
            return Folder(
                url: itemURL,
                notes: notes,
                subfolders: subfolders,
                modifiedDate: resourceValues.contentModificationDate ?? Date(),
                createdDate: resourceValues.creationDate ?? Date(),
                depth: depth,
                isExpanded: false
            )
        }
    }
    
    /// Load notes at a given URL
    private func loadNotes(at url: URL, isOrphan: Bool) -> [Note] {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        
        return contents.compactMap { itemURL -> Note? in
            guard itemURL.pathExtension.lowercased() == "md",
                  let resourceValues = try? itemURL.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey, .creationDateKey]),
                  resourceValues.isDirectory != true else {
                return nil
            }
            
            return Note(
                url: itemURL,
                content: nil, // Lazy load content
                modifiedDate: resourceValues.contentModificationDate ?? Date(),
                createdDate: resourceValues.creationDate ?? Date(),
                isOrphan: isOrphan
            )
        }
    }
    
    // MARK: - Read/Write Content
    
    /// Read content of a note
    func readContent(of note: Note) -> String {
        (try? String(contentsOf: note.url, encoding: .utf8)) ?? ""
    }
    
    /// Write content to a note
    func writeContent(_ content: String, to url: URL) throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Create Operations
    
    /// Create a new folder in root
    @discardableResult
    func createFolder(named name: String) throws -> URL {
        guard let rootURL else {
            throw FileStoreError.rootNotAvailable
        }
        
        let folderURL = rootURL.appendingPathComponent(name)
        
        if fileManager.fileExists(atPath: folderURL.path) {
            throw FileStoreError.alreadyExists
        }
        
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
        reload()
        return folderURL
    }
    
    /// Create a new note in a folder
    @discardableResult
    func createNote(in folderURL: URL, filename: String? = nil) throws -> Note {
        // Determine filename
        let baseName = filename ?? Note.defaultFilename(forFolder: folderURL.lastPathComponent)
        let finalName = nextAvailableFilename(base: baseName, in: folderURL)
        
        let noteURL = folderURL.appendingPathComponent(finalName).appendingPathExtension("md")
        
        // Create empty file
        try "".write(to: noteURL, atomically: true, encoding: .utf8)
        
        let resourceValues = try? noteURL.resourceValues(forKeys: [.contentModificationDateKey, .creationDateKey])
        
        let note = Note(
            url: noteURL,
            content: "",
            modifiedDate: resourceValues?.contentModificationDate ?? Date(),
            createdDate: resourceValues?.creationDate ?? Date(),
            isOrphan: false
        )
        
        reload()
        return note
    }
    
    /// Generate next available filename (handles untitled-1, untitled-2, etc.)
    private func nextAvailableFilename(base: String, in folderURL: URL) -> String {
        let mdExtension = "md"
        
        // Check if base name is available
        let baseURL = folderURL.appendingPathComponent(base).appendingPathExtension(mdExtension)
        if !fileManager.fileExists(atPath: baseURL.path) {
            return base
        }
        
        // Find next available number
        var counter = 1
        while true {
            let numberedName = "\(base)-\(counter)"
            let numberedURL = folderURL.appendingPathComponent(numberedName).appendingPathExtension(mdExtension)
            
            if !fileManager.fileExists(atPath: numberedURL.path) {
                return numberedName
            }
            counter += 1
        }
    }
    
    // MARK: - Rename Operations
    
    /// Rename a note
    func renameNote(at url: URL, to newName: String) throws -> URL {
        let newURL = url.deletingLastPathComponent()
            .appendingPathComponent(newName)
            .appendingPathExtension("md")
        
        if fileManager.fileExists(atPath: newURL.path) {
            throw FileStoreError.alreadyExists
        }
        
        try fileManager.moveItem(at: url, to: newURL)
        reload()
        return newURL
    }
    
    /// Rename a folder
    func renameFolder(at url: URL, to newName: String) throws -> URL {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        
        if fileManager.fileExists(atPath: newURL.path) {
            throw FileStoreError.alreadyExists
        }
        
        try fileManager.moveItem(at: url, to: newURL)
        reload()
        return newURL
    }
    
    // MARK: - Move Operations
    
    /// Move a note to a different folder
    func moveNote(at url: URL, to folderURL: URL) throws -> URL {
        let filename = url.lastPathComponent
        let newURL = folderURL.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: newURL.path) {
            throw FileStoreError.alreadyExists
        }
        
        try fileManager.moveItem(at: url, to: newURL)
        reload()
        return newURL
    }
    
    // MARK: - Delete Operations
    
    /// Delete a note
    func deleteNote(at url: URL) throws {
        try fileManager.removeItem(at: url)
        reload()
    }
    
    /// Delete a folder and its contents
    func deleteFolder(at url: URL) throws {
        try fileManager.removeItem(at: url)
        reload()
    }
    
    // MARK: - Sorting
    
    /// Sort folders and notes by given option
    func sort(by option: SortOption) {
        folders = sortItems(folders, by: option)
        orphanNotes = sortNotes(orphanNotes, by: option)
        
        // Sort notes within each folder
        for i in folders.indices {
            folders[i].notes = sortNotes(folders[i].notes, by: option)
            folders[i].subfolders = sortItems(folders[i].subfolders, by: option)
        }
    }
    
    private func sortItems(_ items: [Folder], by option: SortOption) -> [Folder] {
        switch option {
        case .nameAsc:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDesc:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .modifiedDesc:
            return items.sorted { $0.modifiedDate > $1.modifiedDate }
        case .modifiedAsc:
            return items.sorted { $0.modifiedDate < $1.modifiedDate }
        case .createdDesc:
            return items.sorted { $0.createdDate > $1.createdDate }
        case .createdAsc:
            return items.sorted { $0.createdDate < $1.createdDate }
        }
    }
    
    private func sortNotes(_ notes: [Note], by option: SortOption) -> [Note] {
        switch option {
        case .nameAsc:
            return notes.sorted { $0.filename.localizedCaseInsensitiveCompare($1.filename) == .orderedAscending }
        case .nameDesc:
            return notes.sorted { $0.filename.localizedCaseInsensitiveCompare($1.filename) == .orderedDescending }
        case .modifiedDesc:
            return notes.sorted { $0.modifiedDate > $1.modifiedDate }
        case .modifiedAsc:
            return notes.sorted { $0.modifiedDate < $1.modifiedDate }
        case .createdDesc:
            return notes.sorted { $0.createdDate > $1.createdDate }
        case .createdAsc:
            return notes.sorted { $0.createdDate < $1.createdDate }
        }
    }
    
    // MARK: - Folder Expansion State
    
    /// Toggle folder expansion
    func toggleFolder(_ folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].isExpanded.toggle()
        }
    }
    
    /// Find folder by URL
    func folder(for url: URL) -> Folder? {
        func find(in folders: [Folder]) -> Folder? {
            for folder in folders {
                if folder.url == url { return folder }
                if let found = find(in: folder.subfolders) { return found }
            }
            return nil
        }
        return find(in: folders)
    }
}

// MARK: - Errors

enum FileStoreError: LocalizedError {
    case rootNotAvailable
    case alreadyExists
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .rootNotAvailable:
            return "Storage root is not available"
        case .alreadyExists:
            return "An item with this name already exists"
        case .notFound:
            return "Item not found"
        }
    }
}

