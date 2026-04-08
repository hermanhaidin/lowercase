import SwiftUI

@main
struct lowercaseApp: App {
    @State private var fileStore = FileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(fileStore)
        }
    }
}
