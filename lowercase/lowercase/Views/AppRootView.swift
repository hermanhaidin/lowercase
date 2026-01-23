import SwiftUI

struct AppRootView: View {
    @Environment(FileStore.self) private var fileStore
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if fileStore.shouldShowOnboarding {
                    OnboardingView(onCreateFolder: { navigationPath.append(AppRoute.createFolder) })
                } else {
                    HomeView(navigationPath: $navigationPath)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .createFolder:
                    CreateFolderView()
                case let .editor(note):
                    EditorView(note: note)
                case .settings:
                    SettingsView()
                }
            }
        }
        .onChange(of: fileStore.shouldShowOnboarding) { _, _ in
            navigationPath = NavigationPath()
        }
    }
}
