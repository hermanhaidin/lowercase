import SwiftUI

struct QuickActionsView: View {
    let canMove: Bool
    let onRename: () -> Void
    let onMove: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    QuickActionButton(symbol: ">", title: "rename", role: nil, isSecondarySymbol: true, action: onRename)
                    
                    if canMove {
                        QuickActionButton(symbol: ">", title: "move to", role: nil, isSecondarySymbol: true, action: onMove)
                    }
                }
                
                Section {
                    QuickActionButton(symbol: "!", title: "delete", role: .destructive, isSecondarySymbol: false, action: onDelete)
                        .foregroundStyle(.red)
                }
            }
            .listSectionSpacing(ViewTokens.sheetSectionSpacing)
            .monospaced()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    QuickActionsView(canMove: true, onRename: {}, onMove: {}, onDelete: {})
}
