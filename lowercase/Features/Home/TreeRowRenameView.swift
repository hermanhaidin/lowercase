import SwiftUI

struct TreeRowRenameView: View {
    let row: FlatTreeRow
    let isExpanded: Bool
    @Binding var name: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: Design.Spacing.labelGap) {
            iconGroup

            TextField(
                "",
                text: $name,
                prompt: Text(row.name)
                    .foregroundStyle(Design.Colors.tertiaryLabel)
            )
            .font(.geistPixel)
            .foregroundStyle(Design.Colors.label)
            .tint(Design.Colors.accent)
            .focused(isFocused)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onSubmit(onSubmit)
            .onAppear { isFocused.wrappedValue = true }

            Spacer(minLength: 0)
        }
        .frame(minHeight: Design.Sizing.minRowHeight)
        .padding(.horizontal, Design.Spacing.contentMargin)
    }
}

// MARK: - Private

private extension TreeRowRenameView {
    var iconGroup: some View {
        Group {
            if row.isFolder {
                FolderIconGroup(depth: row.depth, isExpanded: isExpanded)
            } else {
                FileIconGroup(depth: row.depth)
            }
        }
    }
}
