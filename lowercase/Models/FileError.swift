import Foundation

enum FileError: LocalizedError {
    case rootUnavailable
    case alreadyExists(String)
    case invalidMove(String)
    case notFound(URL)
    case readFailed(URL, underlying: Error)
    case writeFailed(URL, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .rootUnavailable:
            "Storage location is not available."
        case .alreadyExists(let name):
            "An item named \"\(name)\" already exists."
        case .invalidMove(let reason):
            reason
        case .notFound(let url):
            "File not found: \(url.lastPathComponent)"
        case .readFailed(_, let underlying):
            "Could not read file: \(underlying.localizedDescription)"
        case .writeFailed(_, let underlying):
            "Could not save file: \(underlying.localizedDescription)"
        }
    }
}
