//
//  SelectFolderView.swift
//  lowercase
//

import SwiftUI

struct SelectFolderView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    /// Called when a note is created - HomeView will handle navigation to Editor
    var onNoteCreated: ((Note) -> Void)
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    @State private var showingSortSheet = false
    
    @FocusState private var isFolderNameFocused: Bool
    
    @ScaledMetric private var gapWidth = ViewTokens.folderRowGap
    @ScaledMetric private var indentWidth = ViewTokens.folderRowIndent
    @ScaledMetric private var folderIconWidth = ViewTokens.folderRowIconSize
    
    var body: some View {
        FolderPickerListView(
            isCreatingFolder: $isCreatingFolder,
            newFolderName: $newFolderName,
            isFolderNameFocused: $isFolderNameFocused,
            folders: fileStore.folders,
            currentFolderURL: nil,
            gapWidth: gapWidth,
            indentWidth: indentWidth,
            folderIconWidth: folderIconWidth,
            showsCurrentLabel: false,
            disableCurrentSelection: false,
            onCreateFolder: createFolderAndNote,
            onSelectFolder: createNoteInFolder
        )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("select folder")
                        .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("sort") { showingSortSheet = true }
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
            .monospaced()
    }
    
    // MARK: - Actions
    
    private func createFolderAndNote() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        do {
            let folderURL = try fileStore.createFolder(named: trimmed)
            let note = try fileStore.createNote(in: folderURL)
            onNoteCreated(note)
        } catch {
            print("Failed to create folder/note: \(error)")
        }
        
        isCreatingFolder = false
        newFolderName = ""
    }
    
    private func createNoteInFolder(_ folder: Folder) {
        do {
            let note = try fileStore.createNote(in: folder.url)
            onNoteCreated(note)
        } catch {
            print("Failed to create note: \(error)")
        }
    }
    
    private func applySort(_ option: SortOption) {
        appState.sortOption = option
        fileStore.sort(by: option)
    }
}

#Preview {
    NavigationStack {
        SelectFolderView { _ in }
            .environment(FileStore())
            .environment(AppState())
    }
}
