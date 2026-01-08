//
//  SettingsView.swift
//  lowercase
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack {
            Form {
                // Appearance
                Section {
                    Picker("Appearance", selection: $appState.appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName)
                                .tag(appearance)
                        }
                    }
                } header: {
                    Text("appearance")
                        .font(.custom("MonacoTTF", size: 14))
                }
                
                // Behavior
                Section {
                    Toggle("Auto-delete empty notes", isOn: $appState.autoDeleteEmptyFiles)
                } header: {
                    Text("behavior")
                        .font(.custom("MonacoTTF", size: 14))
                } footer: {
                    Text("automatically delete new notes that are left empty")
                        .font(.custom("MonacoTTF", size: 12))
                }
                
                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("about")
                        .font(.custom("MonacoTTF", size: 14))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        // Apply inside the sheet so appearance updates immediately while Settings is presented.
        // (Applying only at the app root doesn't reliably live-update an already-presented sheet.)
        .preferredColorScheme(appState.colorScheme)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
