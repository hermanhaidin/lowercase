//
//  HomeNewMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 12.01.2026.
//

import SwiftUI

struct HomeNewMockView: View {
    @ScaledMetric private var gapWidth = 8.0
    @ScaledMetric private var chevronIconWidth = 16.0
    @ScaledMetric private var folderIconWidth = 20.0
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                            
                            Text("xcode-tips")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                            
                            Text("AGENTS")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                            
                            Text("taste")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                            
                            Text("archive")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Orphan notes are shown next to folders in the root
                    // No extra heading
                    // Folders come first, then orphan notes
                    Button {
                        // Open note in editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: chevronIconWidth)
                            
                            Image(systemName: "text.document")
                                .font(.title3.weight(.medium))
                                .symbolRenderingMode(.multicolor)
                                .frame(width: folderIconWidth)
                            
                            Text("untitled-1")
                                .tint(.primary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .contentMargins(.horizontal, 16)
            .monospaced()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("edit") {
                        // Trigger edit mode for selecting folders and files
                    }
                    .fontDesign(.monospaced)
                }
                
                ToolbarItem {
                    Button {
                        // Expand all folders
                    } label: {
                        Image(systemName: "arrow.up.and.down")
                            .font(.caption.bold())
                    }
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem {
                    Button("sort") {
                        // Open sort sheet
                    }
                    .fontDesign(.monospaced)
                }
                
                // MARK: Add note button is part of toolbar
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        // Open sort menu
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "circle.fill")
                                .font(.caption.bold())
                                .foregroundStyle(.green.gradient)
                            
                            Text("local")
                                .fontDesign(.monospaced)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
//                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(role: .confirm) {
                        // Pushes new note view with folder selection instead of showing it in sheet
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption.bold())
                    }
                }
            }
        }
    }
}

#Preview {
    HomeNewMockView()
}
