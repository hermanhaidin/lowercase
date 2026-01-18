//
//  SettingsView.swift
//  lowercase
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
//    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack {
            Form {
                // Appearance
                Section {
                    Picker("appearance", selection: $appState.appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName)
                                .tag(appearance)
                        }
                    }
                }
            }
            .monospaced()
            .scrollBounceBehavior(.basedOnSize)
            .environment(\.defaultMinListRowHeight, ViewTokens.listRowMinHeight)
//            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("settings")
                        .foregroundStyle(.secondary)
                        .monospaced()
                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Close", systemImage: "xmark") { dismiss() }
//                }
            }
        }
        // Apply inside the sheet so appearance updates immediately while Settings is presented.
        // (Applying only at the app root doesn't reliably live-update an already-presented sheet.)
        .preferredColorScheme(appState.colorScheme)
    }
    
}

#Preview {
    SettingsView()
        .environment(AppState())
}
