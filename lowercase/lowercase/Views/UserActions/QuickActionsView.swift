import SwiftUI

struct QuickActionsView: View {
    let canMove: Bool
    let onRename: () -> Void
    let onMove: () -> Void
    let onDelete: () -> Void
    
    @ScaledMetric private var gapWidth = ViewTokens.listRowIconGap
    @ScaledMetric private var iconSize = ViewTokens.folderRowIconSize
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    QuickActionButton(
                        systemImage: "pencil",
                        title: "rename",
                        gapWidth: gapWidth,
                        iconSize: iconSize,
                        role: nil,
                        action: onRename
                    )
                    
                    if canMove {
                        QuickActionButton(
                            systemImage: "folder",
                            title: "move to",
                            gapWidth: gapWidth,
                            iconSize: iconSize,
                            role: nil,
                            action: onMove
                        )
                    }
                }
                
                Section {
                    QuickActionButton(
                        systemImage: "trash",
                        title: "delete",
                        gapWidth: gapWidth,
                        iconSize: iconSize,
                        role: .destructive,
                        action: onDelete
                    )
                        .foregroundStyle(.red)
                }
            }
            .listSectionSpacing(ViewTokens.sheetSectionSpacing)
            .monospaced()
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    QuickActionsView(canMove: true, onRename: {}, onMove: {}, onDelete: {})
}
