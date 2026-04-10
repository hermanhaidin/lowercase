import SwiftUI

struct TreeRowView: View {
    let row: FlatTreeRow
    let isExpanded: Bool
    var onTap: () -> Void
    var onLongPress: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Design.Spacing.labelGap) {
                iconGroup

                Text(row.name)
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.label)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(minHeight: Design.Sizing.minRowHeight)
            .padding(.horizontal, Design.Spacing.contentMargin)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .simultaneousGesture(LongPressGesture().onEnded { _ in onLongPress() })
    }
}

// MARK: - Subviews

private struct FolderIconGroup: View {
    let depth: Int
    let isExpanded: Bool

    var body: some View {
        HStack(spacing: Design.Spacing.iconGap) {
            ForEach(0..<depth, id: \.self) { _ in
                Color.clear
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
            }

            Icon.chevronRight.image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                .foregroundStyle(Design.Colors.tertiaryLabel)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.easeInOut(duration: 0.2), value: isExpanded)

            (isExpanded ? Icon.folderOpen : Icon.folderClosed).image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                .foregroundStyle(Design.Colors.secondaryAccent)
        }
    }
}

private struct FileIconGroup: View {
    let depth: Int

    var body: some View {
        HStack(spacing: Design.Spacing.iconGap) {
            ForEach(0..<depth + 1, id: \.self) { _ in
                Color.clear
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
            }

            Icon.fileText.image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                .foregroundStyle(Design.Colors.tertiaryLabel)
        }
    }
}

// MARK: - Private

private extension TreeRowView {
    var iconGroup: some View {
        Group {
            if row.isFolder {
                FolderIconGroup(depth: row.depth, isExpanded: isExpanded)
            } else {
                FileIconGroup(depth: row.depth)
            }
        }
    }

    var accessibilityLabel: String {
        row.isFolder ? "Folder: \(row.name)" : "Note: \(row.name)"
    }

    var accessibilityHint: String {
        if row.isFolder {
            isExpanded ? "Double tap to collapse" : "Double tap to expand"
        } else {
            "Double tap to open"
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TreeRowView(
            row: FlatTreeRow(
                from: FileNode(id: URL(filePath: "/archive"), name: "archive", isFolder: true, dateCreated: .now, dateModified: .now, children: []),
                depth: 0
            ),
            isExpanded: false,
            onTap: {},
            onLongPress: {}
        )
        TreeRowView(
            row: FlatTreeRow(
                from: FileNode(id: URL(filePath: "/inspo"), name: "inspo", isFolder: true, dateCreated: .now, dateModified: .now, children: [
                    FileNode(id: URL(filePath: "/inspo/child"), name: "child", isFolder: false, dateCreated: .now, dateModified: .now, children: [])
                ]),
                depth: 0
            ),
            isExpanded: true,
            onTap: {},
            onLongPress: {}
        )
        TreeRowView(
            row: FlatTreeRow(
                from: FileNode(id: URL(filePath: "/inspo/note.md"), name: "note", isFolder: false, dateCreated: .now, dateModified: .now, children: []),
                depth: 1
            ),
            isExpanded: false,
            onTap: {},
            onLongPress: {}
        )
        TreeRowView(
            row: FlatTreeRow(
                from: FileNode(id: URL(filePath: "/random.md"), name: "random-ideas", isFolder: false, dateCreated: .now, dateModified: .now, children: []),
                depth: 0
            ),
            isExpanded: false,
            onTap: {},
            onLongPress: {}
        )
    }
    .background(Design.Colors.background)
}
