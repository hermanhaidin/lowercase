import SwiftUI

struct StorageOptionButton: View {
    let systemImage: String
    let title: String
    let gapWidth: CGFloat
    let iconWidth: CGFloat
    let isSelected: Bool
    let showsCheckmark: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: gapWidth) {
                Image(systemName: systemImage)
                    .frame(width: iconWidth)
                
                Text(title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                if showsCheckmark && isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.medium)
                        .foregroundStyle(.tint)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
