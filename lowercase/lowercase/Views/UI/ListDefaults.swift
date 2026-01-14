import SwiftUI

extension View {
    func lcListDefaults() -> some View {
        self
            .lcMonospaced()
            .listSectionSpacing(LCMetrics.listSectionSpacing)
            .scrollBounceBehavior(.basedOnSize)
            .environment(\.defaultMinListRowHeight, 40)
    }
    
    func lcFormDefaults() -> some View {
        self
            .lcMonospaced()
            .scrollBounceBehavior(.basedOnSize)
            .environment(\.defaultMinListRowHeight, 40)
    }
}

