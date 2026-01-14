//
//  HomeView.swift
//  lowercase
//

import SwiftUI

enum HomeDestination: Hashable {
    case newNote
}

struct HomeView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    
    @State private var navigationPath = NavigationPath()
    @State private var showingSettings = false
    
    // Context menu state
    @State private var itemToRename: URL?
    @State private var itemToMove: URL?
    @State private var itemToDelete: URL?
    @State private var isRenamingFolder = false
    @State private var newName = ""
    @State private var showingRenameAlert = false
    @State private var showingDeleteConfirmation = false
    
    private struct MoveTarget: Identifiable {
        let id: URL
        let url: URL
        
        init(_ url: URL) {
            self.id = url
            self.url = url
        }
    }
    
    @State private var moveTarget: MoveTarget?

    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var chevronIconWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            contentList
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { storageSwitcher }
                ToolbarItem(placement: .topBarTrailing) { topMenu }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("Add Note", systemImage: "plus", role: .confirm) {
                        navigationPath.append(HomeDestination.newNote)
                    }
                }
            }
            .navigationDestination(for: Note.self) { note in
                EditorView(note: note)
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .newNote:
                    NewNoteView { note in
                        // Replace NewNoteView with EditorView so Back returns to Home.
                        navigationPath.removeLast()
                        navigationPath.append(note)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $moveTarget) { target in
                MoveToSheet(noteURL: target.url)
            }
            .alert("Rename", isPresented: $showingRenameAlert) {
                TextField("Name", text: $newName)
                Button("Cancel", role: .cancel) {
                    itemToRename = nil
                }
                Button("Rename") {
                    performRename()
                }
            }
            .confirmationDialog(
                "Delete",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) {
                    itemToDelete = nil
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                fileStore.reload()
            }
        }
    }
    
    // MARK: - Context Menu Actions
    
    private func performRename() {
        guard let url = itemToRename else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        do {
            if isRenamingFolder {
                _ = try fileStore.renameFolder(at: url, to: trimmed)
            } else {
                _ = try fileStore.renameNote(at: url, to: trimmed)
            }
        } catch {
            print("Rename failed: \(error)")
        }
        
        itemToRename = nil
        newName = ""
    }
    
    private func performDelete() {
        guard let url = itemToDelete else { return }
        
        do {
            // Check if it's a directory
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    try fileStore.deleteFolder(at: url)
                } else {
                    try fileStore.deleteNote(at: url)
                }
            }
        } catch {
            print("Delete failed: \(error)")
        }
        
        itemToDelete = nil
    }
    
    // MARK: - Context Menu Builders
    
    func folderContextMenu(for folder: Folder) -> some View {
        Group {
            Button {
                itemToRename = folder.url
                isRenamingFolder = true
                newName = folder.name
                showingRenameAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                itemToDelete = folder.url
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func noteContextMenu(for note: Note) -> some View {
        Group {
            Button {
                itemToRename = note.url
                isRenamingFolder = false
                newName = note.filename
                showingRenameAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Button {
                moveTarget = MoveTarget(note.url)
            } label: {
                Label("Move to...", systemImage: "folder")
            }
            
            Divider()
            
            Button(role: .destructive) {
                itemToDelete = note.url
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Content List
    
    private var contentList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(fileStore.folders) { folder in
                    HomeFolderTreeRows(
                        folder: folder,
                        depth: 0,
                        gapWidth: gapWidth,
                        chevronIconWidth: chevronIconWidth,
                        folderIconWidth: folderIconWidth,
                        isExpanded: fileStore.isFolderExpanded,
                        onToggleExpanded: fileStore.toggleFolderExpansion,
                        folderContextMenu: folderContextMenu(for:),
                        noteContextMenu: noteContextMenu(for:)
                    )
                }
                
                ForEach(fileStore.orphanNotes) { note in
                    noteRow(note, depth: 0, isOrphan: true)
                        .contextMenu { noteContextMenu(for: note) }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .lcMonospaced()
        .background(Color(.systemGroupedBackground))
    }
    
    private func noteRow(_ note: Note, depth: Int, isOrphan: Bool) -> some View {
        NavigationLink(value: note) {
            HStack(spacing: gapWidth) {
                if isOrphan {
                    Image(systemName: "questionmark")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: chevronIconWidth)
                } else {
                    Spacer()
                        .frame(width: CGFloat(depth) * chevronIconWidth)
                    Spacer()
                        .frame(width: chevronIconWidth)
                }
                
                Image(systemName: "text.document")
                    .font(.title3.weight(.medium))
                    .symbolRenderingMode(.multicolor)
                    .frame(width: folderIconWidth)
                
                Text(note.filename)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Storage Switcher
    
    private var storageSwitcher: some View {
        Menu {
            // Current roots
            ForEach(StorageRoot.allCases) { root in
                if root.isAvailable(icloudContainer: nil) { // TODO: Pass actual container
                    Button {
                        appState.currentRoot = root
                        fileStore.currentRoot = root
                        fileStore.reload()
                    } label: {
                        HStack {
                            Text(root.displayName)
                            if root == appState.currentRoot {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: gapWidth) {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.green.gradient)
                
                Text(appState.currentRoot.shortName)
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var topMenu: some View {
        Menu {
            Button("Settings") { showingSettings = true }
            
            Menu("Sort by") {
                ForEach(SortOption.allCases) { option in
                    Button {
                        appState.sortOption = option
                        fileStore.sort(by: option)
                    } label: {
                        HStack {
                            Text(option.displayName)
                            if option == appState.sortOption {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
}

private struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

private struct HomeFolderTreeRows<FolderMenu: View, NoteMenu: View>: View {
    let folder: Folder
    let depth: Int
    let gapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let folderIconWidth: CGFloat
    let isExpanded: (URL) -> Bool
    let onToggleExpanded: (URL) -> Void
    @ViewBuilder let folderContextMenu: (Folder) -> FolderMenu
    @ViewBuilder let noteContextMenu: (Note) -> NoteMenu
    
    var body: some View {
        Group {
            folderHeaderRow(folder, depth: depth)
                .contextMenu { folderContextMenu(folder) }
            
            if isExpanded(folder.url) {
                VStack(spacing: 0) {
                    ForEach(folder.notes) { note in
                        NavigationLink(value: note) {
                            noteRowContent(note, depth: depth + 1)
                        }
                        .buttonStyle(.plain)
                        .contextMenu { noteContextMenu(note) }
                    }
                    
                    ForEach(folder.subfolders) { subfolder in
                        HomeFolderTreeRows(
                            folder: subfolder,
                            depth: depth + 1,
                            gapWidth: gapWidth,
                            chevronIconWidth: chevronIconWidth,
                            folderIconWidth: folderIconWidth,
                            isExpanded: isExpanded,
                            onToggleExpanded: onToggleExpanded,
                            folderContextMenu: folderContextMenu,
                            noteContextMenu: noteContextMenu
                        )
                    }
                }
            }
        }
    }
    
    private func folderHeaderRow(_ folder: Folder, depth: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                onToggleExpanded(folder.url)
            }
        } label: {
            HStack(spacing: gapWidth) {
                if depth > 0 {
                    Spacer()
                        .frame(width: CGFloat(depth) * chevronIconWidth)
                }
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: chevronIconWidth)
                    .rotationEffect(.degrees(isExpanded(folder.url) ? 90 : 0))
                
                Image(systemName: "folder.fill")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.blue.gradient)
                    .frame(width: folderIconWidth)
                
                Text(folder.name)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
    
    private func noteRowContent(_ note: Note, depth: Int) -> some View {
        HStack(spacing: gapWidth) {
            Spacer()
                .frame(width: CGFloat(depth) * chevronIconWidth)
            
            Spacer()
                .frame(width: chevronIconWidth)
            
            Image(systemName: "text.document")
                .font(.title3.weight(.medium))
                .symbolRenderingMode(.multicolor)
                .frame(width: folderIconWidth)
            
            Text(note.filename)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView()
        .environment(FileStore())
        .environment(AppState())
}

