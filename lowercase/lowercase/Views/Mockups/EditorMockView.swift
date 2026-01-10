//
//  EditorMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 10.01.2026.
//

import SwiftUI

struct EditorMockView: View {
    @ScaledMetric private var gapWidth = 4.0
    
    @State private var content = ""
    @State private var filename = "untitled-1"
    @State private var folder = "100-days-of-swiftui"
    
    var body: some View {
        NavigationStack {
            TextEditor(text: $content)
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .monospaced()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back", systemImage: "chevron.left") {
                            // Back to home view
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(filename)
                            
                            HStack(spacing: gapWidth) {
                                Image(systemName: "folder")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(Color.secondary.gradient)
                                
                                Text(folder)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .monospaced()
                    }
                    
                    ToolbarItem {
                        Button("Show More", systemImage: "ellipsis") {
                            // Menu with buttons
                            // - Rename
                            // - Move to
                            // - Share in `v1`
                            // - Delete
                        }
                    }
                }
        }
    }
}

#Preview {
    EditorMockView()
}
