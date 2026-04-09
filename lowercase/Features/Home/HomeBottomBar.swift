import SwiftUI

struct HomeBottomBar: View {
    let allExpanded: Bool
    let isEmpty: Bool
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
        .padding(.horizontal, 16)
    }
}

// MARK: - Subviews

private struct ExpandCollapseButton: View {
    let allExpanded: Bool
    let isEmpty: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            (allExpanded ? Icon.chevronDownUp : Icon.arrowUpDown).image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
        }
        .buttonStyle(.glass)
        .frame(width: Design.Sizing.toolbarItemSize, height: Design.Sizing.toolbarItemSize)
        .disabled(isEmpty)
        .accessibilityLabel(allExpanded ? "Collapse all folders" : "Expand all folders")
    }
}

private struct SortButton: View {
    var action: () -> Void

    var body: some View {
        Button("Sort", action: action)
            .font(.geistPixel)
            .buttonStyle(.glass)
            .accessibilityLabel("Sort notes")
    }
}

private struct AddNoteButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Icon.plus.image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
        }
        .buttonStyle(.glassProminent)
        .frame(width: Design.Sizing.toolbarItemSize, height: Design.Sizing.toolbarItemSize)
        .tint(Design.Colors.glassTint)
        .accessibilityLabel("Add note")
    }
}

// MARK: - Private

private extension HomeBottomBar {
    var expandCollapseButton: some View {
        ExpandCollapseButton(allExpanded: allExpanded, isEmpty: isEmpty, action: onToggleExpansion)
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
            isEmpty: false,
            onToggleExpansion: {},
            onSort: {},
            onAdd: {}
        )
    }
    .background(Design.Colors.background)
}
