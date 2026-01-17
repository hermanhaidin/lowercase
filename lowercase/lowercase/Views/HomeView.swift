//
//  HomeView.swift
//  lowercase
//

import SwiftUI

struct HomeView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    
    @State private var showingNewNote = false
    @State private var showingSettingsDestination = false
    @State private var pendingNoteDestination: NoteDestination?
    @State private var showingSortSheet = false
    @State private var showingStorageSheet = false
    @State private var pendingSettingsFromStorage = false
    @State private var quickActionsTarget: QuickActionsTarget?
    @State private var pendingMoveTarget: MoveTarget?
    
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
    
    private enum QuickActionsKind: Equatable {
        case folder
        case note
    }
    
    private struct QuickActionsTarget: Identifiable, Equatable {
        let id: URL
        let url: URL
        let kind: QuickActionsKind
        let name: String
        
        init(url: URL, kind: QuickActionsKind, name: String) {
            self.id = url
            self.url = url
            self.kind = kind
            self.name = name
        }
    }
    
    private struct NoteDestination: Identifiable, Hashable {
        let note: Note
        var id: URL { note.url }
    }

    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var chevronIconWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    var body: some View {
        NavigationStack {
            contentList
            .toolbar {
                // top bar
                ToolbarItem(placement: .topBarLeading) { editButton }
                ToolbarItem { expandCollapseButton }
                ToolbarSpacer(.fixed)
                ToolbarItem { sortButton }
                
                // bottom bar
                ToolbarItem(placement: .bottomBar) { storageSwitcher }
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Note", systemImage: "plus", role: .confirm) {
                        showingNewNote = true
                    }
                }
            }
            .navigationDestination(isPresented: $showingNewNote) {
                NewNoteView { note in
                    pendingNoteDestination = NoteDestination(note: note)
                    showingNewNote = false
                }
            }
            .navigationDestination(isPresented: $showingSettingsDestination) {
                SettingsView()
            }
            .navigationDestination(item: $pendingNoteDestination) { destination in
                EditorView(note: destination.note)
            }
            .sheet(isPresented: $showingSortSheet) {
                SortSheetView(selectedOption: appState.sortOption) { option in
                    applySort(option)
                    showingSortSheet = false
                }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingStorageSheet) {
                StorageSwitcherSheetView(
                    selectedRoot: appState.currentRoot,
                    onSelectLocal: selectLocalRoot,
                    onOpenSettings: {
                        pendingSettingsFromStorage = true
                        showingStorageSheet = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $quickActionsTarget) { target in
                QuickActionsSheetView(
                    canMove: target.kind == .note,
                    onRename: { handleRename(for: target) },
                    onMove: { handleMove(for: target) },
                    onDelete: { handleDelete(for: target) }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
            .onChange(of: quickActionsTarget) { _, newValue in
                guard newValue == nil, let pendingMoveTarget else { return }
                moveTarget = pendingMoveTarget
                self.pendingMoveTarget = nil
            }
            .onChange(of: showingStorageSheet) { _, newValue in
                guard newValue == false, pendingSettingsFromStorage else { return }
                pendingSettingsFromStorage = false
                showingSettingsDestination = true
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
    
    private func handleRename(for target: QuickActionsTarget) {
        itemToRename = target.url
        isRenamingFolder = target.kind == .folder
        newName = target.name
        showingRenameAlert = true
        quickActionsTarget = nil
    }
    
    private func handleMove(for target: QuickActionsTarget) {
        guard target.kind == .note else { return }
        pendingMoveTarget = MoveTarget(target.url)
        quickActionsTarget = nil
    }
    
    private func handleDelete(for target: QuickActionsTarget) {
        itemToDelete = target.url
        showingDeleteConfirmation = true
        quickActionsTarget = nil
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
                        onFolderLongPress: { showQuickActions(for: $0) },
                        onNoteLongPress: { showQuickActions(for: $0) }
                    )
                }
                
                ForEach(fileStore.orphanNotes) { note in
                    noteRow(note, depth: 0, isOrphan: true)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.4)
                                .onEnded { _ in showQuickActions(for: note) }
                        )
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .lcMonospaced()
        .background(Color(.systemGroupedBackground))
    }
    
    private func noteRow(_ note: Note, depth: Int, isOrphan: Bool) -> some View {
        NavigationLink {
            EditorView(note: note)
        } label: {
            HStack(spacing: gapWidth) {
                if isOrphan {
                    Spacer()
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
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Toolbar Buttons
    
    private var editButton: some View {
        Button("edit") { }
            .fontDesign(.monospaced)
    }
    
    private var expandCollapseButton: some View {
        Button {
            toggleAllFolders()
        } label: {
            Image(systemName: areAllFoldersExpanded ? "arrow.down.and.line.horizontal.and.arrow.up" : "arrow.up.and.down")
                .font(.caption.bold())
        }
    }
    
    private var sortButton: some View {
        Button("sort") { showingSortSheet = true }
            .fontDesign(.monospaced)
    }
    
    // MARK: - Storage Switcher
    
    private var storageSwitcher: some View {
        Button {
            showingStorageSheet = true
        } label: {
            HStack(spacing: gapWidth) {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.green.gradient)
                
                Text(appState.currentRoot.shortName)
                    .fontDesign(.monospaced)
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func applySort(_ option: SortOption) {
        appState.sortOption = option
        fileStore.sort(by: option)
    }
    
    private func selectLocalRoot() {
        appState.currentRoot = .local
        fileStore.currentRoot = .local
        fileStore.reload()
    }
    
    private func showQuickActions(for folder: Folder) {
        quickActionsTarget = QuickActionsTarget(url: folder.url, kind: .folder, name: folder.name)
    }
    
    private func showQuickActions(for note: Note) {
        quickActionsTarget = QuickActionsTarget(url: note.url, kind: .note, name: note.filename)
    }
    
    private var areAllFoldersExpanded: Bool {
        let folderURLs = allFolderURLs(from: fileStore.folders)
        return !folderURLs.isEmpty && folderURLs.allSatisfy { fileStore.isFolderExpanded($0) }
    }
    
    private func toggleAllFolders() {
        let folderURLs = allFolderURLs(from: fileStore.folders)
        guard !folderURLs.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            if areAllFoldersExpanded {
                for url in folderURLs where fileStore.isFolderExpanded(url) {
                    fileStore.toggleFolderExpansion(url)
                }
            } else {
                for url in folderURLs where !fileStore.isFolderExpanded(url) {
                    fileStore.toggleFolderExpansion(url)
                }
            }
        }
    }
    
    private func allFolderURLs(from folders: [Folder]) -> [URL] {
        folders.flatMap { folder in
            [folder.url] + allFolderURLs(from: folder.subfolders)
        }
    }
}

private struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

private struct HomeFolderTreeRows: View {
    let folder: Folder
    let depth: Int
    let gapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let folderIconWidth: CGFloat
    let isExpanded: (URL) -> Bool
    let onToggleExpanded: (URL) -> Void
    let onFolderLongPress: (Folder) -> Void
    let onNoteLongPress: (Note) -> Void
    
    var body: some View {
        Group {
            folderHeaderRow(folder, depth: depth)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.4)
                        .onEnded { _ in onFolderLongPress(folder) }
                )
            
            if isExpanded(folder.url) {
                VStack(spacing: 0) {
                    ForEach(folder.notes) { note in
                        NavigationLink {
                            EditorView(note: note)
                        } label: {
                            noteRowContent(note, depth: depth + 1)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.4)
                                .onEnded { _ in onNoteLongPress(note) }
                        )
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
                            onFolderLongPress: onFolderLongPress,
                            onNoteLongPress: onNoteLongPress
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
            .contentShape(.rect)
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
        .contentShape(.rect)
    }
}

#Preview {
    HomeView()
        .environment(FileStore())
        .environment(AppState())
}

