//
//  MoveToSheet.swift
//  lowercase
//

import SwiftUI

struct MoveToSheet: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss
    
    let noteURL: URL
    
    /// Called after a successful move with the new file URL.
    var onMoved: ((URL) -> Void)? = nil
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    
    @FocusState private var isFolderNameFocused: Bool

    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var indentWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if isCreatingFolder {
                        folderNameInputRow
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
                    MoveFolderPickerTreeRows(
                        folder: folder,
                        depth: 0,
                        currentFolderURL: currentFolderURL,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        onSelect: moveNoteToFolder
                    )
                }
            }
            .lcListDefaults()
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
    
    // MARK: - Folder Name Input
    
    private var folderNameInputRow: some View {
        HStack(spacing: gapWidth) {
            TextField("folder name", text: $newFolderName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFolderNameFocused)
                .onSubmit { createFolderAndMove() }
            
            Button("Create") { createFolderAndMove() }
                .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    private var currentFolderURL: URL {
        noteURL.deletingLastPathComponent()
    }
    
    private func folderRow(_ folder: Folder, depth: Int) -> some View {
        let isCurrent = (folder.url == currentFolderURL)
        
        return Button {
            moveNoteToFolder(folder)
        } label: {
            HStack(spacing: gapWidth) {
                if depth > 0 {
                    Spacer().frame(width: CGFloat(depth) * indentWidth)
                }
                
                Image(systemName: "folder.fill")
                    .font(.title3.weight(.medium))
                    .tint(Color.blue.gradient)
                    .frame(width: folderIconWidth)
                    .padding(.leading, 8)
                
                Text(folder.name)
                    .tint(isCurrent ? .secondary : .primary)
                    .lineLimit(1)
                
                Spacer()
                
                if isCurrent {
                    Text("current")
                        .tint(.secondary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .tint(.secondary)
                }
            }
        }
        .disabled(isCurrent)
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

private struct MoveFolderPickerTreeRows: View {
    let folder: Folder
    let depth: Int
    let currentFolderURL: URL
    let gapWidth: CGFloat
    let indentWidth: CGFloat
    let folderIconWidth: CGFloat
    let onSelect: (Folder) -> Void
    
    var body: some View {
        Group {
            Section {
                row(folder, depth: depth)
            }
            .listRowSeparator(.hidden)
            
            if !folder.subfolders.isEmpty {
                ForEach(folder.subfolders) { subfolder in
                    MoveFolderPickerTreeRows(
                        folder: subfolder,
                        depth: depth + 1,
                        currentFolderURL: currentFolderURL,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        onSelect: onSelect
                    )
                }
            }
        }
    }
    
    private func row(_ folder: Folder, depth: Int) -> some View {
        let isCurrent = (folder.url == currentFolderURL)
        
        return Button {
            onSelect(folder)
        } label: {
            HStack(spacing: gapWidth) {
                if depth > 0 {
                    Spacer().frame(width: CGFloat(depth) * indentWidth)
                }
                
                Image(systemName: "folder.fill")
                    .font(.title3.weight(.medium))
                    .tint(Color.blue.gradient)
                    .frame(width: folderIconWidth)
                    .padding(.leading, 8)
                
                Text(folder.name)
                    .tint(isCurrent ? .secondary : .primary)
                    .lineLimit(1)
                
                Spacer()
                
                if isCurrent {
                    Text("current")
                        .tint(.secondary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .tint(.secondary)
                }
            }
        }
        .disabled(isCurrent)
    }
}

#Preview {
    MoveToSheet(noteURL: URL(fileURLWithPath: "/test/daily/note.md"))
        .environment(FileStore())
}
