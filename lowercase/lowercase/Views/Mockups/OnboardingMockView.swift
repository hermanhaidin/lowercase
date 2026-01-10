//
//  OnboardingMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 09.01.2026.
//

import SwiftUI

struct OnboardingMockView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("# your thoughts are yours...")
                    
                    Text("~/lowercase stores notes as files on your device")
                    
                    Text("open them anywhere, even offline")
                }
                .monospaced()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button("Create New Folder", role: .confirm) { }
                    .buttonSizing(.flexible)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .tint(.blue)
            }
            .padding(.horizontal, 34)
        }
    }
}

#Preview {
    OnboardingMockView()
}
