//
//  DeleteConfirmationView.swift
//  lowercase
//
//  Created by Herman Haidin on 21.01.2026.
//

import SwiftUI

struct DeleteConfirmationView: View {
    let name: String
    let isFolder: Bool
    let onDeleteAndDontAsk: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    private var titleText: String {
        if isFolder {
            return "delete \"\(name)\" and all its contents?"
        }
        return "delete \"\(name)\"?"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(titleText)
    
                        Text("it will be moved to your system trash")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                }
                .listRowBackground(Color.clear)
                
                Section {
                    Button("delete and don't ask again", role: .destructive, action: onDeleteAndDontAsk)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section {
                    Button("delete", role: .destructive, action: onDelete)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section {
                    Button("cancel", role: .cancel, action: onCancel)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listSectionSpacing(ViewTokens.sheetSectionSpacing)
            .monospaced()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DeleteConfirmationView(
        name: "untitled-1",
        isFolder: true,
        onDeleteAndDontAsk: {},
        onDelete: {},
        onCancel: {}
    )
}
