//
//  AppState.swift
//  lowercase
//

import Foundation
import SwiftUI

/// App-wide state and settings, persisted to UserDefaults.
@Observable
final class AppState {
    
    // MARK: - Keys
    
    private enum Keys {
        static let currentRoot = "currentRoot"
        static let sortOption = "sortOption"
        static let appearance = "appearance"
        static let autoDeleteEmptyFiles = "autoDeleteEmptyFiles"
    }
    
    // MARK: - Properties
    
    /// Current storage root (iCloud or local)
    var currentRoot: StorageRoot {
        didSet { save(currentRoot.rawValue, forKey: Keys.currentRoot) }
    }
    
    /// Current sort option
    var sortOption: SortOption {
        didSet { save(sortOption.rawValue, forKey: Keys.sortOption) }
    }
    
    /// App appearance setting
    var appearance: AppAppearance {
        didSet { save(appearance.rawValue, forKey: Keys.appearance) }
    }
    
    /// Whether to auto-delete empty untitled files
    var autoDeleteEmptyFiles: Bool {
        didSet { save(autoDeleteEmptyFiles, forKey: Keys.autoDeleteEmptyFiles) }
    }
    
    // MARK: - UserDefaults
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Init
    
    init() {
        // Load persisted values or use defaults
        self.currentRoot = StorageRoot(rawValue: defaults.string(forKey: Keys.currentRoot) ?? "") ?? .local
        
        self.sortOption = SortOption(rawValue: defaults.string(forKey: Keys.sortOption) ?? "") ?? .modifiedDesc
        
        self.appearance = AppAppearance(rawValue: defaults.string(forKey: Keys.appearance) ?? "") ?? .system
        
        // Default true for auto-delete if not set
        if defaults.object(forKey: Keys.autoDeleteEmptyFiles) == nil {
            self.autoDeleteEmptyFiles = true
        } else {
            self.autoDeleteEmptyFiles = defaults.bool(forKey: Keys.autoDeleteEmptyFiles)
        }
    }
    
    // MARK: - Persistence Helpers
    
    private func save(_ value: Any, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    // MARK: - Appearance
    
    /// Get the ColorScheme for SwiftUI based on current appearance setting
    var colorScheme: ColorScheme? {
        appearance.colorScheme
    }
}

// MARK: - App Appearance

/// Available appearance options
enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    /// Convert to SwiftUI ColorScheme (nil = system)
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

