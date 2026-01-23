//
//  OnboardingView.swift
//  lowercase
//

import SwiftUI

struct OnboardingView: View {
    let onCreateFolder: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("# your thoughts are yours")
                
                Text("lowercase stores notes as files on your device")
                
                Text("open them anywhere, even offline")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button("create new folder", role: .confirm) { onCreateFolder() }
                .buttonSizing(.flexible)
                .buttonStyle(.glassProminent)
                .controlSize(.large)
        }
        .monospaced()
        .padding(.horizontal, ViewTokens.bezelPadding)
    }
}

#Preview {
    OnboardingView(onCreateFolder: {})
        .environment(FileStore())
        .environment(AppState())
}
