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
            AppRootView()
            .environment(appState)
            .environment(fileStore)
            .preferredColorScheme(appState.colorScheme)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                fileStore.sortOption = appState.sortOption
                fileStore.reload()
            }
            .onChange(of: appState.sortOption) { _, newValue in
                fileStore.sortOption = newValue
            }
            .onAppear {
                fileStore.sortOption = appState.sortOption
                fileStore.reload()
            }
        }
    }
}
