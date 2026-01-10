//
//  CreateFolderMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 09.01.2026.
//

import SwiftUI

struct CreateFolderMockView: View {
    // Mock property for the text field
    @State private var folderName = ""
    
    // Mock property for the toggle
    @State private var isOn = true
    
    var body: some View {
        NavigationStack {
            Form {
                // Text field as section
                Section {
                    TextField("folder name e.g. daily", text: $folderName)
                }
                
                // iCloud sync toggle as section
                // Section footer is used for extra context
                Section {
                    Toggle("store in iCloud", isOn: $isOn)
                        .tint(.blue)
                } footer: {
                    Text("→ this cannot be changed later")
                        .font(.body)
                }
                
            }
            .monospaced()
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") {
                        // Back to onboarding
                    }
                }
            }
            .safeAreaBar(edge: .bottom) {
                Button("Create", role: .confirm) { }
                    .buttonSizing(.flexible)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .tint(.blue)
                    .padding(.horizontal, 34)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    CreateFolderMockView()
}
