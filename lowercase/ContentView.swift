import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("lowercase")
            .font(.geistPixel)
            .foregroundStyle(Design.Colors.label)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.Colors.background)
    }
}

#Preview {
    ContentView()
}
