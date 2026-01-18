//
//  MoveToFolderView.swift
//  lowercase
//

import SwiftUI

struct MoveToFolderView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let noteURL: URL
    
    /// Called after a successful move with the new file URL.
    var onMoved: ((URL) -> Void)? = nil
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    @State private var showingSortSheet = false
    
    @FocusState private var isFolderNameFocused: Bool

    @ScaledMetric private var gapWidth = ViewTokens.folderRowGap
    @ScaledMetric private var indentWidth = ViewTokens.folderRowIndent
    @ScaledMetric private var folderIconWidth = ViewTokens.folderRowIconSize
    
    var body: some View {
        NavigationStack {
            FolderPickerListView(
                isCreatingFolder: $isCreatingFolder,
                newFolderName: $newFolderName,
                isFolderNameFocused: $isFolderNameFocused,
                folders: fileStore.folders,
                currentFolderURL: currentFolderURL,
                gapWidth: gapWidth,
                indentWidth: indentWidth,
                folderIconWidth: folderIconWidth,
                showsCurrentLabel: true,
                disableCurrentSelection: true,
                onCreateFolder: createFolderAndMove,
                onSelectFolder: moveNoteToFolder
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close", systemImage: "xmark") { dismiss() }
                }
                
                ToolbarItem(placement: .title) {
                    Text("move to")
                        .foregroundStyle(.secondary)
                        .monospaced()
                }
                
                ToolbarItem {
                    Button("sort") { showingSortSheet = true }
                        .monospaced()
                }
            }
            .sheet(isPresented: $showingSortSheet) {
                SortByView(selectedOption: appState.sortOption) { option in
                    applySort(option)
                    showingSortSheet = false
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var currentFolderURL: URL {
        noteURL.deletingLastPathComponent()
    }
    
    // MARK: - Actions
    
    private func createFolderAndMove() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        do {
            let folderURL = try fileStore.createFolder(named: trimmed)
            let newURL = try fileStore.moveNote(at: noteURL, to: folderURL)
            onMoved?(newURL)
            dismiss()
        } catch {
            print("Failed to create folder/move note: \(error)")
        }
        
        isCreatingFolder = false
        newFolderName = ""
    }
    
    private func moveNoteToFolder(_ folder: Folder) {
        do {
            let newURL = try fileStore.moveNote(at: noteURL, to: folder.url)
            onMoved?(newURL)
            dismiss()
        } catch {
            print("Failed to move note: \(error)")
        }
    }
    
    private func applySort(_ option: SortOption) {
        appState.sortOption = option
        fileStore.sort(by: option)
    }
}

#Preview {
    MoveToFolderView(noteURL: URL(fileURLWithPath: "/test/daily/note.md"))
        .environment(FileStore())
}
