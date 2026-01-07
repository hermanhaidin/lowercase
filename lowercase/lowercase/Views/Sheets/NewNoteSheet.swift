//
//  NewNoteSheet.swift
//  lowercase
//
//  Placeholder - will be implemented in Todo 6
//

import SwiftUI

struct NewNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("New Note Sheet")
                .navigationTitle("New Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
}

#Preview {
    NewNoteSheet()
}

