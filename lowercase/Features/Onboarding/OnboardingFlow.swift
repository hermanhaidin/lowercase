import SwiftUI

enum OnboardingDestination: Hashable {
    case newFolder
}

struct OnboardingFlow: View {
    @State private var path: [OnboardingDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingView(onContinue: { path.append(.newFolder) })
                .navigationDestination(for: OnboardingDestination.self) { destination in
                    switch destination {
                    case .newFolder:
                        NewFolderView()
                    }
                }
        }
    }
}

#Preview {
    OnboardingFlow()
        .environment(FileStore())
}
