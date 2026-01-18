//
//  MoveToFolderView.swift
//  lowercase
//

import SwiftUI

struct MoveToFolderView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss
    
    let noteURL: URL
    
    /// Called after a successful move with the new file URL.
    var onMoved: ((URL) -> Void)? = nil
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    
    @FocusState private var isFolderNameFocused: Bool

    @ScaledMetric private var gapWidth = ViewTokens.folderRowGap
    @ScaledMetric private var indentWidth = ViewTokens.folderRowIndent
    @ScaledMetric private var folderIconWidth = ViewTokens.folderRowIconSize
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if isCreatingFolder {
                        FolderNameInputRow(
                            name: $newFolderName,
                            onSubmit: createFolderAndMove,
                            onCreate: createFolderAndMove,
                            isFocused: $isFolderNameFocused
                        )
                    } else {
                        Button {
                            isCreatingFolder = true
                            isFolderNameFocused = true
                        } label: {
                            HStack(spacing: gapWidth) {
                                Image(systemName: "plus")
                                    .frame(width: folderIconWidth)
                                    .padding(.leading, 8)
                                
                                Text("new folder")
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                ForEach(fileStore.folders) { folder in
                    FolderPickerTreeView(
                        folder: folder,
                        depth: 0,
                        currentFolderURL: currentFolderURL,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        iconLeadingPadding: 8,
                        rowPadding: EdgeInsets(),
                        showsChevron: true,
                        showsCurrentLabel: true,
                        disableCurrentSelection: true,
                        hidesRowSeparators: true,
                        onSelect: moveNoteToFolder
                    )
                }
            }
            .monospaced()
            .listSectionSpacing(ViewTokens.listSectionSpacing)
            .scrollBounceBehavior(.basedOnSize)
            .environment(\.defaultMinListRowHeight, ViewTokens.listRowMinHeight)
            .navigationTitle("Move to...")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    MoveToFolderView(noteURL: URL(fileURLWithPath: "/test/daily/note.md"))
        .environment(FileStore())
}
