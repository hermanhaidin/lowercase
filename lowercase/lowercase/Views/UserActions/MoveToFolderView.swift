//
//  MoveToFolderView.swift
//  lowercase
//

import SwiftUI

struct MoveToFolderView: View {
    enum MoveItem: Equatable {
        case note(url: URL)
        case folder(url: URL)
    }

    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let item: MoveItem
    
    /// Called after a successful move with the new file URL.
    var onMoved: ((URL) -> Void)? = nil
    
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
        NavigationStack {
            FolderPickerListView(
                isCreatingFolder: $isCreatingFolder,
                newFolderName: $newFolderName,
                isFolderNameFocused: $isFolderNameFocused,
                folders: filteredFolders,
                currentFolderURL: currentParentURL,
                gapWidth: gapWidth,
                indentWidth: indentWidth,
                folderIconWidth: folderIconWidth,
                showsCurrentLabel: false,
                disableCurrentSelection: false,
                onSubmit: handleSubmit,
                onSelectFolder: moveItemToFolder,
                onSelectRoot: handleSelectRoot
            )
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close", systemImage: "xmark") { dismiss() }
                }
                
                ToolbarItem(placement: .title) {
                    Text("move to")
                        .foregroundStyle(.secondary)
                        .monospaced()
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
    }
    
    private var currentParentURL: URL? {
        itemURL.deletingLastPathComponent()
    }

    private var itemURL: URL {
        switch item {
        case .note(let url):
            return url
        case .folder(let url):
            return url
        }
    }

    private var isMovingFolder: Bool {
        if case .folder = item {
            return true
        }
        return false
    }

    private var filteredFolders: [Folder] {
        guard isMovingFolder else { return fileStore.folders }
        return filteredFolders(fileStore.folders, excluding: itemURL)
    }

    private func filteredFolders(_ folders: [Folder], excluding movingFolderURL: URL) -> [Folder] {
        folders.compactMap { folder in
            if folder.url == movingFolderURL || fileStore.isDescendant(folder.url, of: movingFolderURL) {
                return nil
            }
            var filtered = folder
            filtered.subfolders = filteredFolders(folder.subfolders, excluding: movingFolderURL)
            return filtered
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
            createFolderAndMove()
        }
    }
    
    private func createFolderAndMove() {
        do {
            let folderURL = try fileStore.createFolder(named: trimmedFolderName)
            let newURL = try moveItem(to: folderURL)
            if let newURL {
                onMoved?(newURL)
            }
            dismiss()
        } catch {
            print("Failed to create folder/move item: \(error)")
        }
        
        isCreatingFolder = false
        newFolderName = ""
    }
    
    private func moveItemToFolder(_ folder: Folder) {
        if isNoOpMove(destinationParent: folder.url) {
            dismiss()
            return
        }

        do {
            let newURL = try moveItem(to: folder.url)
            if let newURL {
                onMoved?(newURL)
            }
            dismiss()
        } catch {
            print("Failed to move item: \(error)")
        }
    }

    private func handleSelectRoot() {
        guard let rootURL = fileStore.rootURL else { return }
        if isNoOpMove(destinationParent: rootURL) {
            dismiss()
            return
        }

        do {
            let newURL = try moveItem(to: rootURL)
            if let newURL {
                onMoved?(newURL)
            }
            dismiss()
        } catch {
            print("Failed to move item: \(error)")
        }
    }

    private func isNoOpMove(destinationParent: URL) -> Bool {
        guard let currentParentURL else { return false }
        return destinationParent.standardizedFileURL.path == currentParentURL.standardizedFileURL.path
    }

    private func moveItem(to destinationParent: URL) throws -> URL? {
        switch item {
        case .note(let url):
            return try fileStore.moveNote(at: url, to: destinationParent)
        case .folder(let url):
            return try fileStore.moveFolder(at: url, toParent: destinationParent)
        }
    }
    
    private func applySort(_ option: SortOption) {
        appState.sortOption = option
    }
}

#Preview {
    MoveToFolderView(item: .note(url: URL(fileURLWithPath: "/test/daily/note.md")))
        .environment(FileStore())
        .environment(AppState())
}
