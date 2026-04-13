import SwiftUI

struct FittedPresentationModifier: ViewModifier {
    @State private var height: Double = 0

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: Double.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                height = newHeight
            }
            .presentationDetents(height > 0 ? [.height(height)] : [.medium])
    }
}
