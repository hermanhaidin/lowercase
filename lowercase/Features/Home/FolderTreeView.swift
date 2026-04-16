import SwiftUI

struct FolderTreeView: View {
    @Environment(FileStore.self) private var fileStore

    @Binding var renameTarget: FlatTreeRow?
    @Binding var renameDraft: String
    var renameFocused: FocusState<Bool>.Binding
    var onRenameSubmit: () -> Void
    var onQuickAction: (FlatTreeRow) -> Void
    var onTapFile: (FlatTreeRow) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(fileStore.flatRows) { row in
                        if renameTarget?.id == row.id {
                            TreeRowRenameView(
                                row: row,
                                isExpanded: fileStore.expandedFolders.contains(row.id),
                                name: $renameDraft,
                                isFocused: renameFocused,
                                onSubmit: onRenameSubmit
                            )
                        } else {
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
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: renameTarget?.id) { _, newValue in
                if let id = newValue {
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
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
    @Previewable @State var renameTarget: FlatTreeRow?
    @Previewable @State var draft = ""
    @Previewable @FocusState var focused: Bool

    FolderTreeView(
        renameTarget: $renameTarget,
        renameDraft: $draft,
        renameFocused: $focused,
        onRenameSubmit: {},
        onQuickAction: { _ in },
        onTapFile: { _ in }
    )
    .background(Design.Colors.background)
    .environment(FileStore())
}
