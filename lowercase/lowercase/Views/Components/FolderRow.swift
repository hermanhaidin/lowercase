import SwiftUI

struct FolderRow: View {
    let folder: Folder
    let depth: Int
    let gapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let folderIconWidth: CGFloat
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                onToggleExpanded()
            }
        } label: {
            HStack(spacing: gapWidth) {
                if depth > 0 {
                    Spacer()
                        .frame(width: CGFloat(depth) * chevronIconWidth)
                }
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: chevronIconWidth)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                
                Image(systemName: "folder.fill")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.blue.gradient)
                    .frame(width: folderIconWidth, height: folderIconWidth)
                
                Text(folder.name)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
}

private struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
