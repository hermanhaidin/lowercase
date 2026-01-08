//
//  MoveToSheet.swift
//  lowercase
//

import SwiftUI

struct MoveToSheet: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss
    
    let noteURL: URL
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    
    @FocusState private var isFolderNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 8) {
                    // New folder button at top
                    if isCreatingFolder {
                        folderNameInput
                            .padding(.horizontal)
                    } else {
                        Button {
                            isCreatingFolder = true
                            isFolderNameFocused = true
                        } label: {
                            HStack {
                                Text("+ new folder")
                                    .font(.custom("MonacoTTF", size: 16))
                                    .foregroundStyle(.blue)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    
                    // Folder list
                    ForEach(fileStore.folders) { folder in
                        MoveFolderPickerRow(
                            folder: folder,
                            depth: 0,
                            currentNoteURL: noteURL,
                            onSelect: { selectedFolder in
                                moveNoteToFolder(selectedFolder)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
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
    
    private var folderNameInput: some View {
        HStack {
            TextField("folder name", text: $newFolderName)
                .font(.custom("MonacoTTF", size: 16))
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFolderNameFocused)
                .onSubmit {
                    createFolderAndMove()
                }
            
            Button("Create") {
                createFolderAndMove()
            }
            .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Actions
    
    private func createFolderAndMove() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        do {
            let folderURL = try fileStore.createFolder(named: trimmed)
            _ = try fileStore.moveNote(at: noteURL, to: folderURL)
            dismiss()
        } catch {
            print("Failed to create folder/move note: \(error)")
        }
        
        isCreatingFolder = false
        newFolderName = ""
    }
    
    private func moveNoteToFolder(_ folder: Folder) {
        do {
            _ = try fileStore.moveNote(at: noteURL, to: folder.url)
            dismiss()
        } catch {
            print("Failed to move note: \(error)")
        }
    }
}

// MARK: - Move Folder Picker Row

struct MoveFolderPickerRow: View {
    let folder: Folder
    let depth: Int
    let currentNoteURL: URL
    let onSelect: (Folder) -> Void
    
    /// Check if this folder contains the note being moved
    private var containsCurrentNote: Bool {
        folder.url == currentNoteURL.deletingLastPathComponent()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Folder row
            Button {
                onSelect(folder)
            } label: {
                HStack {
                    Text(folder.name)
                        .font(.custom("MonacoTTF", size: 16))
                        .foregroundStyle(containsCurrentNote ? .secondary : .primary)
                    
                    if containsCurrentNote {
                        Text("(current)")
                            .font(.custom("MonacoTTF", size: 12))
                            .foregroundStyle(.tertiary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .padding(.leading, CGFloat(depth) * 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(containsCurrentNote)
            
            // Subfolders
            if !folder.subfolders.isEmpty {
                ForEach(folder.subfolders) { subfolder in
                    MoveFolderPickerRow(
                        folder: subfolder,
                        depth: depth + 1,
                        currentNoteURL: currentNoteURL,
                        onSelect: onSelect
                    )
                }
            }
        }
        .background(depth == 0 ? Color(.secondarySystemGroupedBackground) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: depth == 0 ? 12 : 0))
    }
}

#Preview {
    MoveToSheet(noteURL: URL(fileURLWithPath: "/test/daily/note.md"))
        .environment(FileStore())
}
