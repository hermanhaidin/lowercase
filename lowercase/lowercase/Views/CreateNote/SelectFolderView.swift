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
        SelectFolderListView(
            isCreatingFolder: $isCreatingFolder,
            newFolderName: $newFolderName,
            isFolderNameFocused: $isFolderNameFocused,
            folders: fileStore.folders,
            gapWidth: gapWidth,
            indentWidth: indentWidth,
            folderIconWidth: folderIconWidth,
            onCreateFolderAndNote: createFolderAndNote,
            onCreateNoteInFolder: createNoteInFolder
        )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("select folder")
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

private struct SelectFolderListView: View {
    @Binding var isCreatingFolder: Bool
    @Binding var newFolderName: String
    @FocusState.Binding var isFolderNameFocused: Bool
    let folders: [Folder]
    let gapWidth: CGFloat
    let indentWidth: CGFloat
    let folderIconWidth: CGFloat
    let onCreateFolderAndNote: () -> Void
    let onCreateNoteInFolder: (Folder) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isCreatingFolder {
                    FolderNameInputRow(
                        name: $newFolderName,
                        onSubmit: onCreateFolderAndNote,
                        onCreate: onCreateFolderAndNote,
                        isFocused: $isFolderNameFocused
                    )
                } else {
                    Button {
                        isCreatingFolder = true
                        isFolderNameFocused = true
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "plus")
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                                .frame(width: folderIconWidth)
                            
                            Text("new folder")
                                .foregroundStyle(.tint)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(folders) { folder in
                    FolderPickerTreeView(
                        folder: folder,
                        depth: 0,
                        currentFolderURL: nil,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        iconLeadingPadding: 0,
                        rowPadding: EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8),
                        showsChevron: true,
                        showsCurrentLabel: false,
                        disableCurrentSelection: false,
                        hidesRowSeparators: false,
                        onSelect: onCreateNoteInFolder
                    )
                }
            }
        }
        .monospaced()
        .contentMargins(.leading, 20)
        .contentMargins([.top, .trailing, .bottom], 16)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    NavigationStack {
        SelectFolderView { _ in }
            .environment(FileStore())
            .environment(AppState())
    }
}
