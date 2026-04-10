import SwiftUI

struct HomeEmptyView: View {
    var body: some View {
        VStack(spacing: 22) {
            Icon.faceUnhappy.image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                .foregroundStyle(Design.Colors.secondaryAccent)

            Text("No notes yet...")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeEmptyView()
        .background(Design.Colors.background)
}
