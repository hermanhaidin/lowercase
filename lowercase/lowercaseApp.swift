import SwiftUI
import UIKit

@main
struct lowercaseApp: App {
    @State private var fileStore = FileStore()

    init() {
        let backImage = UIImage(named: "arrow-left")
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(fileStore)
                .preferredColorScheme(.dark)
        }
    }
}
