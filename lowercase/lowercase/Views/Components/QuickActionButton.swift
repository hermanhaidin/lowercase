import SwiftUI

struct QuickActionButton: View {
    let symbol: String
    let title: String
    let role: ButtonRole?
    let isSecondarySymbol: Bool
    let action: () -> Void
    
    var body: some View {
        Button(role: role) {
            action()
        } label: {
            HStack {
                Text(symbol)
                    .foregroundStyle(isSecondarySymbol ? .secondary : .primary)
                Text(title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
