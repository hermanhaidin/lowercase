//
//  NewNoteMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 10.01.2026.
//

import SwiftUI

struct NewNoteMockView: View {
    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var indentWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    var body: some View {
        NavigationStack {
            List {
                // Every folder is a section in a list
                
                // MARK: Create new folder button as section
                Section {
                    Button {
                        // Change button to a text field
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "plus")
                                .frame(width: folderIconWidth)
                                .padding(.leading, 8)
                            
                            Text("new folder")
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                // MARK: Collapsed folder
                Section {
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                                .padding(.leading, 8)
                            
                            Text("templates")
                                .tint(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                        }
                    }
                }
                
                // MARK: Collapsed folder
                Section {
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                                .padding(.leading, 8)
                            
                            Text("daily")
                                .tint(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                        }
                    }
                }
                
                // MARK: Expanded folder with subfolders
                Section {
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                                .padding(.leading, 8)
                            
                            Text("projects")
                                .tint(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                        }
                    }
                    
                    // Folder row
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: indentWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                                .padding(.leading, 8)
                            
                            Text("100-days-of-swift-ui")
                                .tint(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                        }
                    }
                    
                    // Folder row
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: indentWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                                .padding(.leading, 8)
                            
                            Text("app-ideas")
                                .tint(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .monospaced()
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .listSectionSpacing(8)
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") {
                        // e.g. Back to home view
                    }
                }
                
                ToolbarItem {
                    Button {
                        // Open sort menu
                        // Preserve sort order from home view
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}

#Preview {
    NewNoteMockView()
}
