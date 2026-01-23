//
//  SelectFolderView.swift
//  lowercase
//

import SwiftUI

struct SelectFolderView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    /// Called when a note is created - HomeView will handle navigation to Editor
    var onNoteCreated: ((Note) -> Void)
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    @State private var showingSortSheet = false
    @State private var showDoneButton = false
    
    @FocusState private var isFolderNameFocused: Bool
    
    @ScaledMetric private var gapWidth = ViewTokens.folderRowGap
    @ScaledMetric private var indentWidth = ViewTokens.folderRowIndent
    @ScaledMetric private var folderIconWidth = ViewTokens.folderRowIconSize
    
    @Namespace private var namespace
    
    private var trimmedFolderName: String {
        newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
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
            onSubmit: handleSubmit,
            onSelectFolder: createNoteInFolder
        )
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("close", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .title) {
                Text("select folder")
                    .foregroundStyle(.secondary)
            }
            
            if showDoneButton {
                ToolbarItem {
                    Button {
                        handleSubmit()
                    } label: {
                        Text("done")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                    .glassEffectID("action", in: namespace)
                }
            } else {
                ToolbarItem {
                    Button("sort") { showingSortSheet = true }
                        .glassEffectID("action", in: namespace)
                }
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
        .onChange(of: isFolderNameFocused) { _, focused in
            withAnimation {
                showDoneButton = focused
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        if trimmedFolderName.isEmpty {
            isCreatingFolder = false
            withAnimation {
                isFolderNameFocused = false
            }
        } else {
            createFolderAndNote()
        }
    }
    
    private func createFolderAndNote() {
        do {
            let folderURL = try fileStore.createFolder(named: trimmedFolderName)
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
