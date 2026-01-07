//
//  HomeView.swift
//  lowercase
//

import SwiftUI

struct HomeView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(AppState.self) private var appState
    
    @State private var showingNewNoteSheet = false
    @State private var showingSortMenu = false
    @State private var navigateToSettings = false
    @State private var selectedNote: Note?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if fileStore.folders.isEmpty && fileStore.orphanNotes.isEmpty {
                    emptyState
                } else {
                    contentList
                }
                
                // FAB - only show when not empty (empty state has its own button)
                if !fileStore.folders.isEmpty || !fileStore.orphanNotes.isEmpty {
                    fab
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    storageSwitcher
                }
                
                ToolbarItem {
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                    }
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem {
                    sortMenuButton
                }

            }
            .navigationDestination(for: Note.self) { note in
                EditorView(note: note)
            }
            .sheet(isPresented: $showingNewNoteSheet) {
                NewNoteSheet()
            }
            .onAppear {
                fileStore.reload()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("no notes yet...")
                    .font(.custom("MonacoTTF", size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("start by adding a note")
                    .font(.custom("MonacoTTF", size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("0 folders: 0 notes")
                    .font(.custom("MonacoTTF", size: 18))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            Button {
                showingNewNoteSheet = true
            } label: {
                Text("Add Note")
            }
            .buttonSizing(.flexible)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 34)
    }
    
    // MARK: - Content List
    
    private var contentList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                // Folders
                ForEach(fileStore.folders) { folder in
                    FolderSection(folder: folder)
                }
                
                // Stats footer
                statsFooter
                
                // Orphan notes section
                if !fileStore.orphanNotes.isEmpty {
                    orphanNotesSection
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // Space for FAB
        }
    }
    
    // MARK: - Stats Footer
    
    private var statsFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("→ \(fileStore.folderCount) folders: \(fileStore.noteCount) notes")
                .font(.custom("MonacoTTF", size: 14))
                .foregroundStyle(.secondary)
            
            if !fileStore.orphanNotes.isEmpty {
                Text("→ \(fileStore.orphanNotes.count) notes not in any folder")
                    .font(.custom("MonacoTTF", size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    
    // MARK: - Orphan Notes Section
    
    private var orphanNotesSection: some View {
        VStack(spacing: 0) {
            ForEach(fileStore.orphanNotes) { note in
                NavigationLink(value: note) {
                    HStack {
                        Text("?")
                            .font(.custom("MonacoTTF", size: 16))
                            .foregroundStyle(.secondary)
                        
                        Text(note.filename)
                            .font(.custom("MonacoTTF", size: 16))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - FAB
    
    private var fab: some View {
        Button {
            showingNewNoteSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
        }
        .padding()
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
            HStack(spacing: 8) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text(appState.currentRoot.shortName)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Sort Menu
    
    private var sortMenuButton: some View {
        Menu {
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
        } label: {
            Image(systemName: "ellipsis")
        }
    }
}

// MARK: - Folder Section

struct FolderSection: View {
    @Environment(FileStore.self) private var fileStore
    let folder: Folder
    
    var body: some View {
        VStack(spacing: 0) {
            // Folder header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    fileStore.toggleFolder(folder)
                }
            } label: {
                HStack {
                    Image(systemName: folder.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    
                    Text(folder.name)
                        .font(.custom("MonacoTTF", size: 16))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if folder.isExpanded {
                VStack(spacing: 0) {
                    // Notes in this folder
                    ForEach(folder.notes) { note in
                        NavigationLink(value: note) {
                            HStack {
                                Text(note.filename)
                                    .font(.custom("MonacoTTF", size: 16))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .padding(.leading, 24)
                        }
                    }
                    
                    // Subfolders
                    ForEach(folder.subfolders) { subfolder in
                        SubfolderSection(folder: subfolder, depth: 1)
                    }
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Subfolder Section

struct SubfolderSection: View {
    @Environment(FileStore.self) private var fileStore
    let folder: Folder
    let depth: Int
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Subfolder header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    
                    Text(folder.name)
                        .font(.custom("MonacoTTF", size: 16))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding()
                .padding(.leading, CGFloat(depth) * 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                // Notes
                ForEach(folder.notes) { note in
                    NavigationLink(value: note) {
                        HStack {
                            Text(note.filename)
                                .font(.custom("MonacoTTF", size: 16))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .padding(.leading, CGFloat(depth + 1) * 24)
                    }
                }
                
                // Nested subfolders
                ForEach(folder.subfolders) { subfolder in
                    SubfolderSection(folder: subfolder, depth: depth + 1)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(FileStore())
        .environment(AppState())
}

