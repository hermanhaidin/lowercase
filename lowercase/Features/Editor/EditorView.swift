import SwiftUI

struct EditorView: View {
    let fileURL: URL
    let fileName: String

    @State private var quickActionTarget: FlatTreeRow?
    @State private var moveTarget: FlatTreeRow?
    @State private var pendingMoveTarget: FlatTreeRow?

    var body: some View {
        Text("Editor placeholder")
            .font(.geistPixel)
            .foregroundStyle(Design.Colors.secondaryLabel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.Colors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text(fileName)
                        .font(.geistPixel)
                        .foregroundStyle(Design.Colors.label)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    moreButton
                }
            }
            .sheet(item: $quickActionTarget, onDismiss: {
                if let target = pendingMoveTarget {
                    moveTarget = target
                    pendingMoveTarget = nil
                }
            }) { row in
                QuickActionsSheet(row: row, onMove: { pendingMoveTarget = $0 })
                    .modifier(FittedPresentationModifier())
                    .presentationBackground(Design.Colors.background)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $moveTarget) { row in
                FolderPickerSheet(mode: .move(url: row.id))
            }
    }
}

// MARK: - Subviews

private extension EditorView {
    var moreButton: some View {
        Button {
            quickActionTarget = FlatTreeRow(noteURL: fileURL, name: fileName)
        } label: {
            Label {
                Text("More actions")
            } icon: {
                Icon.moreHorizontal.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.label)
            }
            .labelStyle(.iconOnly)
        }
    }
}

#Preview {
    NavigationStack {
        EditorView(fileURL: URL(filePath: "/test.md"), fileName: "test")
    }
}
