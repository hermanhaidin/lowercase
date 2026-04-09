import SwiftUI

struct SectionCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0, content: content)
            .background(Design.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Sizing.sectionCornerRadius))
    }
}

#Preview {
    VStack(spacing: Design.Spacing.sectionGap) {
        SectionCard {
            Text("Row 1")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)
                .frame(maxWidth: .infinity, minHeight: Design.Sizing.minSectionHeight, alignment: .leading)
                .padding(.horizontal)
        }
    }
    .padding(.horizontal, Design.Spacing.contentMargin)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Design.Colors.background)
}
