//
//  NewNoteSheet.swift
//  lowercase
//

import SwiftUI

struct NewNoteView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    /// Called when a note is created - HomeView will handle navigation to Editor
    var onNoteCreated: ((Note) -> Void)
    
    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    @State private var showingSortSheet = false
    
    @FocusState private var isFolderNameFocused: Bool
    
    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var indentWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    var body: some View {
        folderListView
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
                SortSheetView(selectedOption: appState.sortOption) { option in
                    applySort(option)
                    showingSortSheet = false
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
    
    // MARK: - Folder List View
    
    private var folderListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isCreatingFolder {
                    folderNameInputRow
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
        }
        .lcMonospaced()
        .contentMargins(.leading, 20)
        .contentMargins([.top, .trailing, .bottom], 16)
        .scrollBounceBehavior(.basedOnSize)
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
    
    private func applySort(_ option: SortOption) {
        appState.sortOption = option
        fileStore.sort(by: option)
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
            Button {
                onSelect(folder)
            } label: {
                HStack(spacing: gapWidth) {
                    if depth > 0 {
                        Spacer()
                            .frame(width: CGFloat(depth) * indentWidth)
                    }
                    
                    Image(systemName: "folder.fill")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.blue.gradient)
                        .frame(width: folderIconWidth)
                    
                    Text(folder.name)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            
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
            .environment(AppState())
    }
}
