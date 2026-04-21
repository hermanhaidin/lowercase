import SwiftUI

@Observable
final class EditorAutosaver {
    private var pendingTask: Task<Void, Never>?
    private var lastSavedContent: String = ""
    private let debounce: Duration = .seconds(2)

    func markLoaded(_ content: String) {
        lastSavedContent = content
    }

    func scheduleSave(content: String, to url: URL, using store: FileStore) {
        pendingTask?.cancel()
        pendingTask = Task { [debounce, weak self] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled, let self else { return }
            await performSave(content: content, to: url, using: store)
        }
    }

    func flushImmediate(content: String, to url: URL, using store: FileStore) {
        pendingTask?.cancel()
        pendingTask = Task {
            await self.performSave(content: content, to: url, using: store)
        }
    }

    func cancelPending() {
        pendingTask?.cancel()
        pendingTask = nil
    }

    private func performSave(content: String, to url: URL, using store: FileStore) async {
        guard content != lastSavedContent else { return }
        do {
            try await store.writeNote(content, to: url)
            lastSavedContent = content
        } catch let error as FileError {
            store.currentError = error
        } catch { }
    }
}
