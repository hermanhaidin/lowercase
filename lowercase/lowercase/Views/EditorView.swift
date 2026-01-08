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
    @State private var isEditingFilename = false
    @State private var showingMoreMenu = false
    @State private var showingMoveSheet = false
    @State private var showingRenameAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var newFilename: String = ""
    
    @FocusState private var isEditorFocused: Bool
    
    // Auto-save debounce
    @State private var saveTask: Task<Void, Never>?
    
    var body: some View {
        TextEditor(text: $content)
            .padding(.horizontal)
            .font(.custom("MonacoTTF", size: 18))
            .scrollContentBackground(.hidden)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($isEditorFocused)
            .onChange(of: content) { _, _ in
                scheduleAutoSave()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        newFilename = filename
                        showingRenameAlert = true
                    } label: {
                        Text(filename)
                            .font(.custom("MonacoTTF", size: 18))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    moreMenuButton
                }
                
                // Keyboard accessory - hide keyboard button
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            isEditorFocused = false
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        handleBackNavigation()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .alert("Rename", isPresented: $showingRenameAlert) {
                TextField("Filename", text: $newFilename)
                Button("Cancel", role: .cancel) { }
                Button("Rename") {
                    renameNote()
                }
            }
            .confirmationDialog("Delete Note", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteNote()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
            }
            .sheet(isPresented: $showingMoveSheet) {
                MoveToSheet(noteURL: note.url)
            }
            .onAppear {
                loadContent()
            }
            .onDisappear {
                // Cancel any pending save
                saveTask?.cancel()
                // Final save
                saveContent()
            }
    }
    
    // MARK: - More Menu
    
    private var moreMenuButton: some View {
        Menu {
            Button {
                newFilename = filename
                showingRenameAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Button {
                showingMoveSheet = true
            } label: {
                Label("Move to...", systemImage: "folder")
            }
            
            Divider()
            
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    // MARK: - Content Management
    
    private func loadContent() {
        content = fileStore.readContent(of: note)
        filename = note.filename
    }
    
    private func saveContent() {
        guard let url = currentNoteURL else { return }
        try? fileStore.writeContent(content, to: url)
    }
    
    private var currentNoteURL: URL? {
        // If renamed, use new URL; otherwise use original
        if filename != note.filename {
            return note.url.deletingLastPathComponent()
                .appendingPathComponent(filename)
                .appendingPathExtension("md")
        }
        return note.url
    }
    
    // MARK: - Auto-Save
    
    private func scheduleAutoSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(1))
            if !Task.isCancelled {
                await MainActor.run {
                    saveContent()
                }
            }
        }
    }
    
    // MARK: - Back Navigation
    
    private func handleBackNavigation() {
        // Cancel pending save
        saveTask?.cancel()
        
        // Check if should auto-delete
        if shouldAutoDelete {
            try? fileStore.deleteNote(at: note.url)
        } else {
            saveContent()
        }
        
        dismiss()
    }
    
    private var shouldAutoDelete: Bool {
        guard appState.autoDeleteEmptyFiles else { return false }
        
        // Only delete if content is empty and filename is unchanged (default name)
        let isEmpty = content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasDefaultName = note.hasDefaultFilename && filename == note.filename
        
        return isEmpty && hasDefaultName
    }
    
    // MARK: - Actions
    
    private func renameNote() {
        let trimmed = newFilename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != filename else { return }
        
        do {
            // Save current content first
            saveContent()
            // Rename the file
            _ = try fileStore.renameNote(at: note.url, to: trimmed)
            filename = trimmed
        } catch {
            // Handle error - could show alert
            print("Rename failed: \(error)")
        }
    }
    
    private func deleteNote() {
        saveTask?.cancel()
        try? fileStore.deleteNote(at: note.url)
        dismiss()
    }
}

// MARK: - Move To Sheet Placeholder

struct MoveToSheet: View {
    @Environment(\.dismiss) private var dismiss
    let noteURL: URL
    
    var body: some View {
        NavigationStack {
            Text("Move to...")
                .navigationTitle("Move to...")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
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
