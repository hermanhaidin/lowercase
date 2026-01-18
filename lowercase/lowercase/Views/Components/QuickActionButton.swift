import SwiftUI

struct QuickActionButton: View {
    let systemImage: String
    let title: String
    let gapWidth: CGFloat
    let iconSize: CGFloat
    let role: ButtonRole?
    let action: () -> Void
    
    var body: some View {
        Button(role: role) {
            action()
        } label: {
            HStack(spacing: gapWidth) {
                Image(systemName: systemImage)
                    .frame(width: iconSize, height: iconSize)
                
                Text(title)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
