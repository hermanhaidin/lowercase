//
//  OnboardingView.swift
//  lowercase
//

import SwiftUI

struct OnboardingView: View {
    @Environment(FileStore.self) private var fileStore
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("your thoughts are yours...")
                        .font(.custom("MonacoTTF", size: 18))
                        .foregroundStyle(.primary)
                    
                    Text("lowercase stores notes as files on your device")
                        .font(.custom("MonacoTTF", size: 18))
                        .foregroundStyle(.secondary)
                    
                    Text("open them anywhere, even offline")
                        .font(.custom("MonacoTTF", size: 18))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    navigationPath.append("createFolder")
                } label: {
                    Text("Create New Folder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "createFolder" {
                    CreateFolderView()
                    // After folder creation, fileStore.shouldShowOnboarding becomes false,
                    // which swaps the root view to HomeView automatically
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(FileStore())
        .environment(AppState())
}
