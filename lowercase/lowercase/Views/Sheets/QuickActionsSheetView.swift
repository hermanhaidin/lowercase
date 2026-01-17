import SwiftUI

struct QuickActionsSheetView: View {
    let canMove: Bool
    let onRename: () -> Void
    let onMove: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    quickActionButton(symbol: ">", title: "rename", role: nil, action: onRename)
                    
                    if canMove {
                        quickActionButton(symbol: ">", title: "move to", role: nil, action: onMove)
                    }
                }
                
                Section {
                    quickActionButton(symbol: "!", title: "delete", role: .destructive, action: onDelete, isSecondarySymbol: false)
                        .foregroundStyle(.red)
                }
            }
            .listSectionSpacing(16)
            .lcMonospaced()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func quickActionButton(
        symbol: String,
        title: String,
        role: ButtonRole?,
        action: @escaping () -> Void,
        isSecondarySymbol: Bool = true
    ) -> some View {
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

#Preview {
    QuickActionsSheetView(canMove: true, onRename: {}, onMove: {}, onDelete: {})
}
