//
//  CreateFolderView.swift
//  lowercase
//

import SwiftUI

struct CreateFolderView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss
    
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
        VStack(spacing: 24) {
            // Folder name input
            VStack(alignment: .leading, spacing: 8) {
                TextField("folder name e.g. daily", text: $folderName)
                    .font(.custom("MonacoTTF", size: 16))
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isNameFocused)
                    .onSubmit {
                        if canCreate {
                            createFolder()
                        }
                    }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.custom("MonacoTTF", size: 14))
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            // Create button
            Button {
                createFolder()
            } label: {
                Text("Create")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canCreate)
        }
        .padding()
        .navigationTitle("New Folder")
        .navigationBarTitleDisplayMode(.inline)
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
            
            dismiss()
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
