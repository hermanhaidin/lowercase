import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("home")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Design.Colors.background)
        }
    }
}

#Preview {
    HomeView()
}
