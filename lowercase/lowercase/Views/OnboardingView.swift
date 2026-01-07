//
//  OnboardingView.swift
//  lowercase
//
//  Placeholder - will be implemented in Todo 7
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("your thoughts are yours...")
                    .font(.custom("MonacoTTF", size: 18))
                
                Text("lowercase stores notes as files on your device")
                    .font(.custom("MonacoTTF", size: 18))
                
                Text("open them anywhere, even offline")
                    .font(.custom("MonacoTTF", size: 18))
            }
            
            Spacer()
            
            NavigationLink(destination: CreateFolderView()) {
                Text("Create New Folder")
            }
            .buttonSizing(.flexible)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 34)
    }
}

// Placeholder for CreateFolderView
struct CreateFolderView: View {
    var body: some View {
        Text("Create Folder")
            .navigationTitle("New Folder")
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}

