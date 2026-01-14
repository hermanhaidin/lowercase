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
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("# your thoughts are yours...")
                    
                    Text("~/lowercase stores notes as files on your device")
                    
                    Text("open them anywhere, even offline")
                }
                .lcMonospaced()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button("Create New Folder", role: .confirm) {
                    navigationPath.append("createFolder")
                }
                .lcPrimaryActionButton()
            }
            .padding(.horizontal, LCMetrics.bezelPadding)
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
