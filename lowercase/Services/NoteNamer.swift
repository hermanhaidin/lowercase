import Foundation

enum NoteNamer {

    /// Returns the next note name for a given folder.
    /// If the folder name contains "daily", returns today's date as YYYY.MM.DD.
    /// Otherwise, returns "untitled-N" where N is the next available integer.
    static func nextName(in folderURL: URL) -> String {
        let folderName = folderURL.lastPathComponent.lowercased()

        if folderName.contains("daily") {
            return dailyName()
        } else {
            return untitledName(in: folderURL)
        }
    }

    /// Returns the URL of today's daily note if it already exists, nil otherwise.
    static func dailyNoteExists(in folderURL: URL) -> URL? {
        let name = dailyName()
        let noteURL = folderURL.appending(path: "\(name).md")
        if FileManager.default.fileExists(atPath: noteURL.path(percentEncoded: false)) {
            return noteURL
        }
        return nil
    }

    // MARK: - Private

    private static func dailyName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y.MM.dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: .now)
    }

    private static func untitledName(in folderURL: URL) -> String {
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        let existingNames = Set(contents.map {
            $0.deletingPathExtension().lastPathComponent
        })

        var n = 1
        while existingNames.contains("untitled-\(n)") {
            n += 1
        }
        return "untitled-\(n)"
    }
}
