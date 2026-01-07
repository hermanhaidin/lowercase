//
//  lowercaseApp.swift
//  lowercase
//
//  Created by Herman Haidin on 02.01.2026.
//

import SwiftUI

@main
struct lowercaseApp: App {
    @State private var appState = AppState()
    @State private var fileStore = FileStore()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if fileStore.shouldShowOnboarding {
                    NavigationStack {
                        OnboardingView()
                    }
                } else {
                    HomeView()
                }
            }
            .environment(appState)
            .environment(fileStore)
            .preferredColorScheme(appState.colorScheme)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                fileStore.reload()
            }
            .onAppear {
                fileStore.reload()
            }
        }
    }
}
