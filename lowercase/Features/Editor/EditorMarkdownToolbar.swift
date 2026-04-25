import SwiftUI

struct EditorMarkdownToolbar: View {
    var onAction: (MarkdownAction) -> Void
    var onHideKeyboard: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            scrollableActions
            hideKeyboardButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Subviews

private struct ActionButton: View {
    let action: MarkdownAction
    var onTap: (MarkdownAction) -> Void

    var body: some View {
        Button {
            onTap(action)
        } label: {
            Label {
                Text(action.accessibilityLabel)
            } icon: {
                action.icon.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.label)
            }
            .labelStyle(.iconOnly)
        }
        .frame(width: Design.Sizing.toolbarItemSize, height: Design.Sizing.toolbarItemSize)
        .contentShape(Rectangle())
    }
}

private struct HideKeyboardButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text("Hide keyboard")
            } icon: {
                Icon.chevronDown.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.label)
            }
            .labelStyle(.iconOnly)
        }
        .frame(width: Design.Sizing.toolbarItemSize, height: Design.Sizing.toolbarItemSize)
        .glassEffect(.regular.tint(Design.Colors.glassTint).interactive(), in: .circle)
    }
}

// MARK: - Private

private extension EditorMarkdownToolbar {
    var scrollableActions: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(MarkdownAction.allCases) { action in
                    ActionButton(action: action, onTap: onAction)
                }
            }
            .padding(.horizontal, 10)
        }
        .scrollIndicators(.hidden)
        .frame(height: Design.Sizing.toolbarItemSize)
        .glassEffect(.regular.interactive(), in: .capsule)
    }

    var hideKeyboardButton: some View {
        HideKeyboardButton(action: onHideKeyboard)
    }
}

#Preview {
    VStack {
        Spacer()
        EditorMarkdownToolbar(
            onAction: { _ in },
            onHideKeyboard: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Design.Colors.background)
}
