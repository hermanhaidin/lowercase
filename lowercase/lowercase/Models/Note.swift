//
//  Note.swift
//  lowercase
//

import Foundation

/// Represents a markdown note file.
struct Note: Identifiable, Hashable {
    /// File URL serves as unique identifier
    var id: URL { url }
    
    /// Full file URL
    let url: URL
    
    /// Filename without extension (e.g., "2026-01-07" or "untitled-1")
    var filename: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    /// File content (loaded separately, may be nil if not yet loaded)
    var content: String?
    
    /// Last modified date from file system
    var modifiedDate: Date
    
    /// Creation date from file system
    var createdDate: Date
    
    /// Whether the note is in root directory (not in any folder)
    var isOrphan: Bool
    
    /// Parent folder name (nil if orphan)
    var folderName: String? {
        isOrphan ? nil : url.deletingLastPathComponent().lastPathComponent
    }
    
    // MARK: - Filename Generation
    
    /// Generates a filename for a new note based on folder name.
    /// - Parameter folderName: The folder where the note will be created
    /// - Returns: "yyyy-MM-dd" if folder contains "daily", otherwise "untitled"
    static func defaultFilename(forFolder folderName: String) -> String {
        if folderName.localizedCaseInsensitiveContains("daily") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        }
        return "untitled"
    }
    
    /// Checks if this note has the default untitled or date-based name.
    var hasDefaultFilename: Bool {
        filename.starts(with: "untitled") || isDateFilename
    }
    
    /// Checks if filename matches yyyy-MM-dd pattern.
    private var isDateFilename: Bool {
        let pattern = #"^\d{4}-\d{2}-\d{2}$"#
        return filename.range(of: pattern, options: .regularExpression) != nil
    }
}

