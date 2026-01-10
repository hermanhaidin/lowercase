//
//  HomeMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 09.01.2026.
//

import SwiftUI

struct HomeMockView: View {
    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var chevronIconWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Every folder is a section in a list
                // MARK: Collapsed folder
                Section {
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("templates")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                
                // MARK: Expanded folder with notes
                Section {
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "chevron.down")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("daily")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Note row
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("2026-01-08")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Note row
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("2026-01-07")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                // MARK: Expanded folder with subfolders
                Section {
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "chevron.down")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("projects")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Folder row
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "chevron.down")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("100-days-of-swift-ui")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Note row
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("swift-ui-tips")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Folder row
                    Button {
                        // Expand or collapse folder
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .tint(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("app-ideas")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                // MARK: Stats footer
                Section {
                    VStack(alignment: .leading) {
                        Text("→ 5 folders: 10 notes")
                        
                        // If orfan notes exist
                        Text("→ 3 notes not in any folder")
                    }
                    .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)
                
                // MARK: Orphan notes
                Section {
                    // Orphan note row
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "questionmark")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("untitled-3")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Orphan note row
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "questionmark")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("untitled-2")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Orphan note row
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "questionmark")
                                .font(.subheadline.bold())
                                .tint(.secondary)
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("untitled-1")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .monospaced()
            .listSectionSpacing(8)
            .scrollBounceBehavior(.basedOnSize)
            // MARK: Toolbar with top and bottom buttons
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Open sort menu
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green.gradient)
                            
                            Text("Local")
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem {
                    Button {
                        // Open menu with:
                        // - Settings
                        // - Sort by
                        // "Sort by" opens a nested menu with sort options
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                
                // MARK: Add note button is part of toolbar
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    
                    Button("Add Note", systemImage: "plus", role: .confirm) {
                        // Pushes new note view with folder selection instead of showing it in sheet
                    }
                }
            }
        }
    }
}

#Preview {
    HomeMockView()
}
