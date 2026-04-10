import SwiftUI

struct HomeBottomBar: View {
    let allExpanded: Bool
    var onToggleExpansion: () -> Void
    var onSort: () -> Void
    var onAdd: () -> Void

    var body: some View {
        HStack {
            expandCollapseButton

            Spacer()

            sortButton

            Spacer()

            addNoteButton
        }
        .padding(.horizontal, Design.Spacing.buttonMargin)
    }
}

// MARK: - Subviews

private struct ExpandCollapseButton: View {
    let allExpanded: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(allExpanded ? "Collapse all folders" : "Expand all folders")
            } icon: {
                (allExpanded ? Icon.chevronDownUp : Icon.arrowUpDown).image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.label)
            }
            .labelStyle(.iconOnly)
        }
        .frame(width: Design.Sizing.toolbarItemSize, height: Design.Sizing.toolbarItemSize)
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

private struct SortButton: View {
    var action: () -> Void

    var body: some View {
        Button("Sort", action: action)
            .font(.geistPixel)
            .foregroundStyle(Design.Colors.label)
            .frame(height: Design.Sizing.toolbarItemSize)
            .padding(.horizontal, Design.Spacing.labelGap)
            .glassEffect(.regular.interactive(), in: .capsule)
            .accessibilityLabel("Sort notes")
    }
}

private struct AddNoteButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text("Add note")
            } icon: {
                Icon.plus.image
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

private extension HomeBottomBar {
    var expandCollapseButton: some View {
        ExpandCollapseButton(allExpanded: allExpanded, action: onToggleExpansion)
    }

    var sortButton: some View {
        SortButton(action: onSort)
    }

    var addNoteButton: some View {
        AddNoteButton(action: onAdd)
    }
}

#Preview {
    VStack {
        Spacer()
        HomeBottomBar(
            allExpanded: false,
            onToggleExpansion: {},
            onSort: {},
            onAdd: {}
        )
    }
    .background(Design.Colors.background)
}
