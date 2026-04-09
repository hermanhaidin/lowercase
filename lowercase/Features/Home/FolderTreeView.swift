import SwiftUI

struct FolderTreeView: View {
    @Environment(FileStore.self) private var fileStore

    var onQuickAction: (FlatTreeRow) -> Void
    var onTapFile: (FlatTreeRow) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(fileStore.flatRows) { row in
                    TreeRowView(
                        row: row,
                        isExpanded: fileStore.expandedFolders.contains(row.id),
                        onTap: { handleTap(row) },
                        onLongPress: { onQuickAction(row) }
                    )
                }
            }
        }
    }
}

// MARK: - Private

private extension FolderTreeView {
    func handleTap(_ row: FlatTreeRow) {
        if row.isFolder {
            withAnimation {
                fileStore.toggleExpansion(for: row.id)
            }
        } else {
            onTapFile(row)
        }
    }
}

#Preview {
    FolderTreeView(onQuickAction: { _ in }, onTapFile: { _ in })
        .background(Design.Colors.background)
        .environment(FileStore())
}
