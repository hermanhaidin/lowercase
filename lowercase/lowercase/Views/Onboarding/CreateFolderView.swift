//
//  CreateFolderView.swift
//  lowercase
//

import SwiftUI

struct CreateFolderView: View {
    @Environment(FileStore.self) private var fileStore
    /// Callback when folder is created - passes folder URL
    var onFolderCreated: ((URL) -> Void)?
    
    /// Whether to also create a note after folder creation
    var createNoteAfterFolder: Bool = false
    
    /// Callback when note is created - passes the note
    var onNoteCreated: ((Note) -> Void)?
    
    @State private var folderName = ""
    @State private var errorMessage: String?
    
    @FocusState private var isNameFocused: Bool
    
    private var canCreate: Bool {
        !folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("folder name e.g. daily", text: $folderName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isNameFocused)
                        .onSubmit {
                            if canCreate { createFolder() }
                        }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .monospaced()
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaBar(edge: .bottom) {
            Button("create", role: .confirm) { createFolder() }
                .buttonSizing(.flexible)
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .monospaced()
                .padding(.horizontal, ViewTokens.bezelPadding)
                .padding(.bottom, isNameFocused ? 16 : 0)
                .disabled(!canCreate)
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("new folder")
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
        }
        .onAppear {
            isNameFocused = true
        }
    }
    
    private func createFolder() {
        let trimmed = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        do {
            let folderURL = try fileStore.createFolder(named: trimmed)
            
            if createNoteAfterFolder {
                // Create note and callback
                let note = try fileStore.createNote(in: folderURL)
                onNoteCreated?(note)
            } else {
                // Just callback with folder
                onFolderCreated?(folderURL)
            }
            
        } catch FileStoreError.alreadyExists {
            errorMessage = "a folder with this name already exists"
        } catch {
            errorMessage = "failed to create folder"
        }
    }
}

#Preview {
    NavigationStack {
        CreateFolderView()
    }
    .environment(FileStore())
}
