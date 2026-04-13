import SwiftUI

struct StorageSwitcherSheet: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SectionCard {
            ForEach(StorageRoot.allCases) { root in
                if root != StorageRoot.allCases.first {
                    sectionDivider
                }

                rootRow(root)
            }
        }
        .padding(.horizontal)
        .padding(.top, Design.Spacing.buttonMargin)
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

// MARK: - Subviews

private struct RootRow: View {
    let root: StorageRoot
    let isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.labelGap) {
                root.icon.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.secondaryAccent)

                Text(root.displayName)
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.label)

                Spacer()

                if isActive {
                    Icon.check.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                        .foregroundStyle(Design.Colors.accent)
                }
            }
            .frame(minHeight: Design.Sizing.minSectionHeight)
            .padding(.horizontal)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(root.displayName)\(isActive ? ", selected" : "")")
    }
}

// MARK: - Private

private extension StorageSwitcherSheet {
    var sectionDivider: some View {
        Rectangle()
            .fill(Design.Colors.separator)
            .frame(height: 1)
            .padding(.horizontal)
    }

    func rootRow(_ root: StorageRoot) -> some View {
        RootRow(root: root, isActive: fileStore.activeRoot == root) {
            switchTo(root)
        }
    }

    func switchTo(_ root: StorageRoot) {
        guard root != fileStore.activeRoot else {
            dismiss()
            return
        }
        dismiss()
        Task {
            try? await fileStore.switchRoot(to: root)
        }
    }
}

#Preview {
    StorageSwitcherSheet()
        .modifier(FittedPresentationModifier())
        .presentationBackground(Design.Colors.background)
        .environment(FileStore())
}
