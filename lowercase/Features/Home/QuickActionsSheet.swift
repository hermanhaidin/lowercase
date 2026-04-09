import SwiftUI

struct QuickActionsSheet: View {
    let row: FlatTreeRow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Design.Spacing.sectionGap) {
            if !row.isFolder {
                shareSection
            }

            editSection

            deleteSection
        }
        .padding(.horizontal, Design.Spacing.contentMargin)
        .padding(.top, Design.Spacing.contentMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Subviews

private struct ActionRow: View {
    let icon: Icon
    let label: String
    var color: Color = Design.Colors.label
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.labelGap) {
                icon.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(color)

                Text(label)
                    .font(.geistPixel)
                    .foregroundStyle(color)

                Spacer()
            }
            .frame(minHeight: Design.Sizing.minSectionHeight)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: - Private

private extension QuickActionsSheet {
    var shareSection: some View {
        SectionCard {
            ActionRow(icon: .share, label: "Share") { dismiss() }
        }
    }

    var editSection: some View {
        SectionCard {
            ActionRow(icon: .pencilEdit, label: "Rename") { dismiss() }

            sectionDivider

            ActionRow(icon: .folderDependent, label: "Move to...") { dismiss() }
        }
    }

    var deleteSection: some View {
        SectionCard {
            ActionRow(icon: .trash, label: "Delete", color: Design.Colors.accent) { dismiss() }
        }
    }

    var sectionDivider: some View {
        Rectangle()
            .fill(Design.Colors.separator)
            .frame(height: 1)
            .padding(.horizontal)
    }
}

#Preview("Note actions") {
    QuickActionsSheet(
        row: FlatTreeRow(
            from: FileNode(id: URL(filePath: "/note.md"), name: "note", isFolder: false, dateCreated: .now, dateModified: .now, children: []),
            depth: 0
        )
    )
    .presentationDetents([.medium])
    .presentationBackground(Design.Colors.background)
}

#Preview("Folder actions") {
    QuickActionsSheet(
        row: FlatTreeRow(
            from: FileNode(id: URL(filePath: "/folder"), name: "folder", isFolder: true, dateCreated: .now, dateModified: .now, children: []),
            depth: 0
        )
    )
    .presentationDetents([.medium])
    .presentationBackground(Design.Colors.background)
}
