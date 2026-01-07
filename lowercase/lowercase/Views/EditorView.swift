//
//  EditorView.swift
//  lowercase
//
//  Placeholder - will be implemented in Todo 5
//

import SwiftUI

struct EditorView: View {
    let note: Note
    
    var body: some View {
        Text("Editor: \(note.filename)")
            .navigationTitle(note.filename)
    }
}

#Preview {
    NavigationStack {
        EditorView(note: Note(
            url: URL(fileURLWithPath: "/test/example.md"),
            content: "Hello",
            modifiedDate: Date(),
            createdDate: Date(),
            isOrphan: false
        ))
    }
}

