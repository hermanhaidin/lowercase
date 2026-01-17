//
//  QuickActionsMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 16.01.2026.
//

import SwiftUI

struct QuickActionsMockView: View {
    var body: some View {
        NavigationStack {
            Form {
                // rename + move to
                Section {
                    Button {
                        
                    } label: {
                        HStack {
                            Text(">")
                                .foregroundStyle(.secondary)
                            Text("rename")
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    
                    HStack {
                        Text(">")
                            .foregroundStyle(.secondary)
                        Text("move to")
                    }
                }
                
                // delete
                Section {
                    Button(role: .destructive) {
                        
                    } label: {
                        HStack {
                            Text("!")
                            Text("delete")
                            
                        }
                    }
                }
            }
            .listSectionSpacing(16)
            .monospaced()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    QuickActionsMockView()
}
