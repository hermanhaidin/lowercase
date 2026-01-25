//
//  HomeView.swift
//  lowercase
//

import SwiftUI

struct HomeView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    
    @Binding var navigationPath: NavigationPath
    
    @State private var showingNewNoteSheet = false
    @State private var showingSortSheet = false
    @State private var showingStorageSheet = false
    @State private var pendingRouteAfterSheet: AppRoute?
    @State private var quickActionsTarget: QuickActionsTarget?
    @State private var pendingMoveTarget: MoveTarget?
    
    // Context menu state
    @State private var itemToRename: URL?
    @State private var itemToMove: URL?
    @State private var isRenamingFolder = false
    @State private var newName = ""
    @State private var showingRenameAlert = false
    @State private var deleteTarget: QuickActionsTarget?
    @State private var pendingDeleteTarget: QuickActionsTarget?
    
    private struct MoveTarget: Identifiable {
        let item: MoveToFolderView.MoveItem

        var id: URL {
            switch item {
            case .note(let url):
                return url
            case .folder(let url):
                return url
            }
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
    
    @ScaledMetric private var folderGapWidth = ViewTokens.folderRowGap
    @ScaledMetric private var noteGapWidth = ViewTokens.noteRowGap
    @ScaledMetric private var chevronIconWidth = ViewTokens.disclosureIconSize
    @ScaledMetric private var folderIconWidth = ViewTokens.folderRowIconSize
    @ScaledMetric private var noteIconWidth = ViewTokens.noteRowIconSize
    
    var body: some View {
        HomeContentList(
            folders: fileStore.folders,
            orphanNotes: fileStore.orphanNotes,
            folderGapWidth: folderGapWidth,
            noteGapWidth: noteGapWidth,
            chevronIconWidth: chevronIconWidth,
            folderIconWidth: folderIconWidth,
            noteIconWidth: noteIconWidth,
            isExpanded: fileStore.isFolderExpanded,
            onToggleExpanded: fileStore.toggleFolderExpansion,
            onFolderLongPress: { showQuickActions(for: $0) },
            onNoteLongPress: { showQuickActions(for: $0) }
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { editButton }
            ToolbarItem(placement: .automatic) { expandCollapseButton }
            ToolbarSpacer(.fixed)
            ToolbarItem(placement: .automatic) { sortButton }
        }
        .safeAreaBar(edge: .bottom) {
            HStack {
                storageSwitcher
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .buttonStyle(.plain)
                
                Button {
                    showingNewNoteSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                }
                .glassEffect(.regular.tint(.blue).interactive(), in: .circle)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showingNewNoteSheet) {
            NavigationStack {
                SelectFolderView { note in
                    showingNewNoteSheet = false
                    navigationPath.append(AppRoute.editor(note))
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
        .sheet(isPresented: $showingStorageSheet, onDismiss: handleStorageSheetDismiss) {
            StorageSwitcherView(
                selectedRoot: appState.currentRoot,
                onSelectLocal: selectLocalRoot,
                onOpenSettings: {
                    pendingRouteAfterSheet = .settings
                    showingStorageSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $quickActionsTarget) { target in
            QuickActionsView(
                canMove: true,
                onRename: { handleRename(for: target) },
                onMove: { handleMove(for: target) },
                onDelete: { handleDelete(for: target) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $moveTarget) { target in
            MoveToFolderView(item: target.item)
        }
        .sheet(item: $deleteTarget) { target in
            DeleteConfirmationView(
                name: target.name,
                isFolder: target.kind == .folder,
                onDeleteAndDontAsk: {
                    appState.skipDeleteConfirmation = true
                    deleteTarget = nil
                    performDelete(for: target)
                },
                onDelete: {
                    deleteTarget = nil
                    performDelete(for: target)
                },
                onCancel: {
                    deleteTarget = nil
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
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
        .onAppear {
            fileStore.reload()
        }
        .onChange(of: quickActionsTarget) { _, newValue in
            guard newValue == nil else { return }
            if let pendingMoveTarget {
                moveTarget = pendingMoveTarget
                self.pendingMoveTarget = nil
            }
            if let pendingDeleteTarget {
                deleteTarget = pendingDeleteTarget
                self.pendingDeleteTarget = nil
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
    
    private func performDelete(for target: QuickActionsTarget) {
        do {
            if target.kind == .folder {
                try fileStore.deleteFolder(at: target.url)
            } else {
                try fileStore.deleteNote(at: target.url)
            }
        } catch {
            print("Delete failed: \(error)")
        }
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
        switch target.kind {
        case .folder:
            pendingMoveTarget = MoveTarget(item: .folder(url: target.url))
        case .note:
            pendingMoveTarget = MoveTarget(item: .note(url: target.url))
        }
        quickActionsTarget = nil
    }
    
    private func handleDelete(for target: QuickActionsTarget) {
        quickActionsTarget = nil
        if appState.skipDeleteConfirmation {
            performDelete(for: target)
        } else {
            pendingDeleteTarget = target
        }
    }
    
    // MARK: - Content List
    
    // MARK: - Toolbar Buttons
    
    private var editButton: some View {
        Button("edit") { }
            .monospaced()
    }
    
    private var expandCollapseButton: some View {
        Button {
            toggleAllFolders()
        } label: {
            Image(systemName: areAllFoldersExpanded ? "arrow.down.and.line.horizontal.and.arrow.up" : "arrow.up.and.down")
                .font(.subheadline)
        }
    }
    
    private var sortButton: some View {
        Button("sort") { showingSortSheet = true }
            .monospaced()
    }
    
    // MARK: - Storage Switcher
    
    private var storageSwitcher: some View {
        Button {
            showingStorageSheet = true
        } label: {
            HStack(spacing: folderGapWidth) {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.green.gradient)
                
                Text(appState.currentRoot.shortName)
                    .monospaced()
                
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.secondary)
            }
            .frame(height: 48)
            .padding(.horizontal)
        }
    }

    private func applySort(_ option: SortOption) {
        appState.sortOption = option
    }
    
    private func selectLocalRoot() {
        appState.currentRoot = .local
        fileStore.currentRoot = .local
        fileStore.reload()
    }

    private func handleStorageSheetDismiss() {
        guard let pendingRouteAfterSheet else { return }
        let route = pendingRouteAfterSheet
        self.pendingRouteAfterSheet = nil
        Task {
            await Task.yield()
            navigationPath.append(route)
        }
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

private struct HomeContentList: View {
    let folders: [Folder]
    let orphanNotes: [Note]
    let folderGapWidth: CGFloat
    let noteGapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let folderIconWidth: CGFloat
    let noteIconWidth: CGFloat
    let isExpanded: (URL) -> Bool
    let onToggleExpanded: (URL) -> Void
    let onFolderLongPress: (Folder) -> Void
    let onNoteLongPress: (Note) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(folders) { folder in
                    FolderTreeView(
                        folder: folder,
                        depth: 0,
                        folderGapWidth: folderGapWidth,
                        noteGapWidth: noteGapWidth,
                        chevronIconWidth: chevronIconWidth,
                        folderIconWidth: folderIconWidth,
                        noteIconWidth: noteIconWidth,
                        isExpanded: isExpanded,
                        onToggleExpanded: onToggleExpanded,
                        onFolderLongPress: onFolderLongPress,
                        onNoteLongPress: onNoteLongPress
                    )
                }
                
                ForEach(orphanNotes) { note in
                    NavigationLink(value: AppRoute.editor(note)) {
                        NoteRow(
                            note: note,
                            depth: 0,
                            isOrphan: true,
                            gapWidth: noteGapWidth,
                            chevronIconWidth: chevronIconWidth,
                            noteIconWidth: noteIconWidth
                        )
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.4)
                            .onEnded { _ in onNoteLongPress(note) }
                    )
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .monospaced()
    }
}

#Preview {
    HomeViewPreview()
}

private struct HomeViewPreview: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .environment(FileStore())
                .environment(AppState())
        }
    }
}

