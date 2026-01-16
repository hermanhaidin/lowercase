//
//  StorageRoot.swift
//  lowercase
//

import Foundation

/// Represents available storage locations.
enum StorageRoot: String, CaseIterable, Identifiable {
    case local = "local"
    case icloud = "icloud"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .local:
            return "On My iPhone"
        case .icloud:
            return "iCloud"
        }
    }
    
    /// Short display name for toolbar
    var shortName: String {
        switch self {
        case .local:
            return "local"
        case .icloud:
            return "icloud"
        }
    }
    
    /// Base path for this storage root.
    /// For local: Documents directory (appears as "On My iPhone/lowercase/" in Files.app)
    /// For iCloud: ubiquity container's Documents folder (appears as "iCloud Drive/lowercase/")
    func baseURL(localDocuments: URL, icloudContainer: URL?) -> URL? {
        switch self {
        case .local:
            // Documents dir IS the app folder in Files.app ("On My iPhone/lowercase/")
            return localDocuments
        case .icloud:
            // Documents subfolder IS the app folder in iCloud Drive ("iCloud Drive/lowercase/")
            return icloudContainer?.appendingPathComponent("Documents")
        }
    }
    
    /// Check if this storage root is available.
    func isAvailable(icloudContainer: URL?) -> Bool {
        switch self {
        case .local:
            return true
        case .icloud:
            return icloudContainer != nil
        }
    }
}

// MARK: - Sort Options

/// Available sort options for folders and notes.
enum SortOption: String, CaseIterable, Identifiable {
    case nameAsc = "name_asc"
    case nameDesc = "name_desc"
    case modifiedDesc = "modified_desc"
    case modifiedAsc = "modified_asc"
    case createdDesc = "created_desc"
    case createdAsc = "created_asc"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .nameAsc: return "Name (A → Z)"
        case .nameDesc: return "Name (Z → A)"
        case .modifiedDesc: return "Modified (New → Old)"
        case .modifiedAsc: return "Modified (Old → New)"
        case .createdDesc: return "Created (New → Old)"
        case .createdAsc: return "Created (Old → New)"
        }
    }
}

