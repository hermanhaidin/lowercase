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
            ScrollView {
                VStack(spacing: 0) {
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "plus")
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                                .frame(width: folderIconWidth)
                            
                            Text("new folder")
                                .foregroundStyle(.tint)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("templates")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("daily")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("projects")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Spacer()
                                .frame(width: indentWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("100-days-of-swift-ui")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {                            
                            Spacer()
                                .frame(width: indentWidth)
                            
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("app-ideas")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("taste")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // open editor
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "folder.fill")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.blue.gradient)
                                .frame(width: folderIconWidth)
                            
                            Text("archive")
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .monospaced()
            .contentMargins(.leading, 20)
            .contentMargins([.top, .trailing, .bottom], 16)
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") {
                        // e.g. Back to home view
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("select folder")
                        .foregroundStyle(.secondary)
                        .monospaced()
                }
                
                ToolbarItem {
                    Button("sort") {
                        // Open sort menu
                        // Preserve sort order from home view
                    }
                    .monospaced()
                }
            }
        }
    }
}

#Preview {
    NewNoteMockView()
}
