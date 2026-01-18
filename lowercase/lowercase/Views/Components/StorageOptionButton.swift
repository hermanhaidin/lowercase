import SwiftUI

struct StorageOptionButton: View {
    let systemImage: String
    let title: String
    let iconWidth: CGFloat
    let isSelected: Bool
    let showsCheckmark: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack {
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
        }
        .buttonStyle(.plain)
    }
}
