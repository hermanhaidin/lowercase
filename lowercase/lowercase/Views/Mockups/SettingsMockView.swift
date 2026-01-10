//
//  SettingsMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 10.01.2026.
//

import SwiftUI

struct SettingsMockView: View {
    @Environment(\.dismiss) var dismiss
    
    @ScaledMetric private var gapWidth = 8.0
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Appearance
                Section {
                    // Custom monospaced picker
                    Button {
                        // Open menu
                    } label: {
                        HStack {
                            Text("appearance")
                                .tint(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: gapWidth) {
                                Text("system")
                                    .tint(.secondary)
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.subheadline.weight(.medium))
                                    .tint(.secondary)
                            }
                        }
                    }
                }
            }
            .monospaced()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        // Close settings
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsMockView()
}
