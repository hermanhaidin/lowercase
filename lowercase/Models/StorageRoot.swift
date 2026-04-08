import Foundation

enum StorageRoot: String, CaseIterable, Identifiable {
    case local
    case iCloud

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .local: "On My iPhone"
        case .iCloud: "iCloud Drive"
        }
    }

    var icon: Icon {
        switch self {
        case .local: .devicePhone
        case .iCloud: .cloud
        }
    }

    var isAvailable: Bool {
        switch self {
        case .local: true
        case .iCloud: FileManager.default.ubiquityIdentityToken != nil
        }
    }
}
