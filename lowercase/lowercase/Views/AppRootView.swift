import SwiftUI

struct AppRootView: View {
    @Environment(FileStore.self) private var fileStore
    @State private var navigationPath = NavigationPath()
    
    private enum Route: Hashable {
        case createFolder
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if fileStore.shouldShowOnboarding {
                    OnboardingView(onCreateFolder: { navigationPath.append(Route.createFolder) })
                } else {
                    HomeView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .createFolder:
                    CreateFolderView()
                }
            }
        }
        .onChange(of: fileStore.shouldShowOnboarding) { _, _ in
            navigationPath = NavigationPath()
        }
    }
}
