import SwiftUI

extension View {
    /// Full-width primary action button used in onboarding/creation flows.
    func lcPrimaryActionButton(tint: Color = .blue) -> some View {
        self
            .buttonSizing(.flexible)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(tint)
    }
}

