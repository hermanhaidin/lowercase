import Foundation

enum RenameTarget: Equatable, Identifiable {
    case folder(url: URL)
    case note(url: URL)
    
    var id: URL {
        switch self {
        case .folder(let url), .note(let url):
            return url
        }
    }
}
