//
//  Folder.swift
//  lowercase
//

import Foundation

/// Represents a folder containing notes.
struct Folder: Identifiable, Hashable {
    /// Folder URL serves as unique identifier
    var id: URL { url }
    
    /// Full folder URL
    let url: URL
    
    /// Folder name (last path component)
    var name: String {
        url.lastPathComponent
    }
    
    /// Notes contained in this folder (loaded separately)
    var notes: [Note]
    
    /// Subfolders (for nested structure)
    var subfolders: [Folder]
    
    /// Last modified date (most recent of folder or its contents)
    var modifiedDate: Date
    
    /// Creation date from file system
    var createdDate: Date
    
    /// Depth level in hierarchy (0 = top level)
    var depth: Int
    
    /// Whether the folder is currently expanded in UI
    var isExpanded: Bool
    
    // MARK: - Computed Properties
    
    /// Total note count including subfolders
    var totalNoteCount: Int {
        notes.count + subfolders.reduce(0) { $0 + $1.totalNoteCount }
    }
    
    /// Total folder count including this folder and all nested subfolders
    var totalFolderCount: Int {
        1 + subfolders.reduce(0) { $0 + $1.totalFolderCount }
    }
    
    /// Whether this is a "daily" folder (for special filename handling)
    var isDaily: Bool {
        name.localizedCaseInsensitiveContains("daily")
    }
    
    // MARK: - Init
    
    init(
        url: URL,
        notes: [Note] = [],
        subfolders: [Folder] = [],
        modifiedDate: Date = Date(),
        createdDate: Date = Date(),
        depth: Int = 0,
        isExpanded: Bool = false
    ) {
        self.url = url
        self.notes = notes
        self.subfolders = subfolders
        self.modifiedDate = modifiedDate
        self.createdDate = createdDate
        self.depth = depth
        self.isExpanded = isExpanded
    }
}

