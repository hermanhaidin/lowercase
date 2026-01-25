//
//  EditorView.swift
//  lowercase
//

import SwiftUI

struct EditorView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let note: Note
    
    @State private var content: String = ""
    @State private var filename: String = ""
    @State private var noteURL: URL
    @State private var isEditingFilename = false
    @State private var showingMoreMenu = false
    @State private var showingMoveSheet = false
    @State private var showingRenameAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var showingQuickActions = false
    @State private var pendingDeleteConfirmation = false
    @State private var newFilename: String = ""
    @State private var pendingMoveSourceURL: URL?

    @FocusState private var isEditorFocused: Bool

    @ScaledMetric private var titleGap = ViewTokens.editorTitleGap
    
    // Auto-save debounce
    @State private var saveTask: Task<Void, Never>?
    @State private var saveGeneration = 0
    
    // Prevent double-finalization (e.g. custom Back triggers dismiss, then onDisappear fires)
    @State private var didFinalizeExit = false
    
    init(note: Note) {
        self.note = note
        _noteURL = State(initialValue: note.url)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $content)
                .padding(.horizontal)
                .monospaced()
                .scrollContentBackground(.hidden)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isEditorFocused)
                .onChange(of: content) { _, _ in
                    scheduleAutoSave()
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if isEditorFocused {
                HStack {
                    Spacer()
                    Button {
                        isEditorFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .frame(width: 48, height: 48)
                    }
                    .glassEffect(.regular.interactive(), in: .circle)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .toolbar {
            ToolbarItem(placement: .title) { titleStack }
            ToolbarItem(placement: .automatic) { showMoreButton }
        }
        .alert("Rename", isPresented: $showingRenameAlert) {
            TextField("Filename", text: $newFilename)
            Button("Cancel", role: .cancel) { }
            Button("Rename") {
                renameNote()
            }
        }
        .sheet(isPresented: $showingDeleteConfirmation) {
            DeleteConfirmationView(
                name: filename,
                isFolder: false,
                onDeleteAndDontAsk: {
                    appState.skipDeleteConfirmation = true
                    showingDeleteConfirmation = false
                    deleteNote()
                },
                onDelete: {
                    showingDeleteConfirmation = false
                    deleteNote()
                },
                onCancel: {
                    showingDeleteConfirmation = false
                }
            )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingQuickActions) {
            QuickActionsView(
                canMove: true,
                onRename: {
                    newFilename = filename
                    showingRenameAlert = true
                    showingQuickActions = false
                },
                onMove: {
                    pendingMoveSourceURL = noteURL
                    invalidatePendingSaves()
                    showingMoveSheet = true
                    showingQuickActions = false
                },
                onDelete: {
                    showingQuickActions = false
                    if appState.skipDeleteConfirmation {
                        deleteNote()
                    } else {
                        pendingDeleteConfirmation = true
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingMoveSheet) {
            MoveToFolderView(
                item: .note(url: noteURL),
                onMoved: { newURL in
                    // Update the editor to keep saving to the moved location (prevents "copy" behavior)
                    let oldURL = pendingMoveSourceURL
                    noteURL = newURL
                    filename = newURL.deletingPathExtension().lastPathComponent
                    if let oldURL, oldURL != newURL, FileManager.default.fileExists(atPath: oldURL.path) {
                        try? fileStore.deleteNote(at: oldURL)
                    }
                    pendingMoveSourceURL = nil
                    fileStore.reload()
                }
            )
        }
        .onAppear {
            loadContent()
        }
        .onDisappear {
            finalizeExitIfNeeded()
        }
        .onChange(of: showingQuickActions) { _, newValue in
            guard newValue == false, pendingDeleteConfirmation else { return }
            pendingDeleteConfirmation = false
            showingDeleteConfirmation = true
        }
    }

    private var titleStack: some View {
        VStack {
            Button {
                newFilename = filename
                showingRenameAlert = true
            } label: {
                Text(filename)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .monospaced()
    }
    
    private var folderLabel: String {
        if note.isOrphan {
            return "root"
        }
        return noteURL.deletingLastPathComponent().lastPathComponent
    }
    
    // MARK: - More Menu
    
    private var showMoreButton: some View {
        Button {
            showingQuickActions = true
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    // MARK: - Content Management
    
    private func loadContent() {
        // Load from the current URL (note can be moved/renamed while editor is open).
        content = (try? String(contentsOf: noteURL, encoding: .utf8)) ?? ""
        filename = noteURL.deletingPathExtension().lastPathComponent
    }
    
    private func saveContent(synchronously: Bool = false) {
        guard let url = currentNoteURL else { return }
        if synchronously {
            try? fileStore.writeContent(content, to: url)
        } else {
            // Avoid blocking the main thread (can manifest as keyboard/tap delays).
            fileStore.writeContentAsync(content, to: url)
        }
    }
    
    private var currentNoteURL: URL? {
        // If renamed, use new URL; otherwise use original
        let baseDir = noteURL.deletingLastPathComponent()
        let baseFilename = noteURL.deletingPathExtension().lastPathComponent
        if filename != baseFilename {
            return baseDir
                .appending(path: filename)
                .appendingPathExtension("md")
        }
        return noteURL
    }
    
    // MARK: - Auto-Save
    
    private func scheduleAutoSave() {
        saveTask?.cancel()
        let generation = saveGeneration
        let targetURL = currentNoteURL?.standardizedFileURL
        saveTask = Task {
            try? await Task.sleep(for: .seconds(1))
            if !Task.isCancelled {
                await MainActor.run {
                    guard generation == saveGeneration else { return }
                    guard let targetURL, targetURL == currentNoteURL?.standardizedFileURL else { return }
                    fileStore.writeContentAsync(content, to: targetURL)
                }
            }
        }
    }
    
    // MARK: - Back Navigation
    
    private func finalizeExitIfNeeded() {
        guard !didFinalizeExit else { return }
        didFinalizeExit = true
        
        // Cancel pending save and flush final state synchronously.
        invalidatePendingSaves()
        
        if shouldAutoDelete {
            // Delete the note and do NOT recreate it by saving on disappear.
            try? fileStore.deleteNote(at: currentNoteURL ?? noteURL)
        } else {
            saveContent()
            // Ensure HomeView reflects latest note list immediately when navigating back.
            fileStore.reload()
        }
    }
    
    private var shouldAutoDelete: Bool {
        guard appState.autoDeleteEmptyFiles else { return false }
        
        // Only delete if content is empty and filename is unchanged (default name)
        let isEmpty = content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let baseFilename = noteURL.deletingPathExtension().lastPathComponent
        let hasDefaultName = (baseFilename.starts(with: "untitled") || isDateFilename(baseFilename))
            && filename == baseFilename
        
        return isEmpty && hasDefaultName
    }
    
    private func isDateFilename(_ name: String) -> Bool {
        let pattern = #"^\d{4}-\d{2}-\d{2}$"#
        return name.range(of: pattern, options: .regularExpression) != nil
    }
    
    // MARK: - Actions
    
    private func renameNote() {
        let trimmed = newFilename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != filename else { return }
        
        do {
            // Cancel pending async writes to avoid recreating the old filename.
            invalidatePendingSaves()
            // Save current content synchronously before moving the file.
            saveContent(synchronously: true)
            // Rename the file
            let newURL = try fileStore.renameNote(at: noteURL, to: trimmed)
            noteURL = newURL
            filename = trimmed
        } catch {
            // Handle error - could show alert
            print("Rename failed: \(error)")
        }
    }
    
    private func deleteNote() {
        invalidatePendingSaves()
        didFinalizeExit = true
        try? fileStore.deleteNote(at: currentNoteURL ?? noteURL)
        dismiss()
    }

    private func invalidatePendingSaves() {
        saveGeneration &+= 1
        saveTask?.cancel()
    }
}

#Preview {
    NavigationStack {
        EditorView(note: Note(
            url: URL(fileURLWithPath: "/test/example.md"),
            content: "Hello world",
            modifiedDate: Date(),
            createdDate: Date(),
            isOrphan: false
        ))
    }
    .environment(FileStore())
    .environment(AppState())
}
