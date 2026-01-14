//
//  NewNoteSheet.swift
//  lowercase
//

import SwiftUI

struct NewNoteView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss
    
    /// Called when a note is created - HomeView will handle navigation to Editor
    var onNoteCreated: ((Note) -> Void)
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    
    @FocusState private var isFolderNameFocused: Bool
    
    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var indentWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    var body: some View {
        folderListView
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") { dismiss() }
                }
                
                ToolbarItem {
                    Button { } label: { Image(systemName: "ellipsis") }
                }
            }
    }
    
    // MARK: - Folder List View
    
    private var folderListView: some View {
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
                FolderPickerTreeRows(
                    folder: folder,
                    depth: 0,
                    gapWidth: gapWidth,
                    indentWidth: indentWidth,
                    folderIconWidth: folderIconWidth,
                    onSelect: createNoteInFolder
                )
            }
        }
        .lcListDefaults()
    }
    
    private func folderRow(_ folder: Folder, depth: Int) -> some View {
        Button {
            createNoteInFolder(folder)
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
                    .tint(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .tint(.secondary)
            }
        }
    }
    
    private var folderNameInputRow: some View {
        HStack(spacing: gapWidth) {
            TextField("folder name", text: $newFolderName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFolderNameFocused)
                .onSubmit { createFolderAndNote() }
            
            Button("Create") { createFolderAndNote() }
                .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
}

private struct FolderPickerTreeRows: View {
    let folder: Folder
    let depth: Int
    let gapWidth: CGFloat
    let indentWidth: CGFloat
    let folderIconWidth: CGFloat
    let onSelect: (Folder) -> Void
    
    var body: some View {
        Group {
            Section {
                Button {
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
                            .tint(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                            .tint(.secondary)
                    }
                }
            }
            
            if !folder.subfolders.isEmpty {
                ForEach(folder.subfolders) { subfolder in
                    FolderPickerTreeRows(
                        folder: subfolder,
                        depth: depth + 1,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        onSelect: onSelect
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewNoteView { _ in }
            .environment(FileStore())
    }
}
