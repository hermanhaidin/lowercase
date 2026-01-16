//
//  SortMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 15.01.2026.
//

import SwiftUI

struct SortMockView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            HStack(spacing: 0) {
                                Text("name:")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(" a to z")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            HStack(spacing: 0) {
                                Text("name:")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(" z to a")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                
                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            HStack(spacing: 0) {
                                Text("modified:")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(" new to old")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            HStack(spacing: 0) {
                                Text("modified:")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(" old to new")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                
                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            HStack(spacing: 0) {
                                Text("created:")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(" new to old")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            HStack(spacing: 0) {
                                Text("created:")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(" old to new")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .monospaced()
            .listSectionSpacing(16)
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.defaultMinListRowHeight, 44)
        }
    }
}

#Preview {
    SortMockView()
}
