import SwiftUI

struct SortSheet: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Design.Spacing.sectionGap) {
            ForEach(SortCriterion.allCases) { criterion in
                criterionSection(criterion)
            }
        }
        .padding(.horizontal, Design.Spacing.contentMargin)
        .padding(.top, Design.Spacing.buttonMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Subviews

private struct SortRow: View {
    let criterion: SortCriterion
    let ascending: Bool
    let isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.labelGap) {
                Text("\(criterion.displayName):")
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.label)

                Text(criterion.directionLabel(ascending: ascending))
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.secondaryLabel)

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
        .accessibilityLabel("\(criterion.displayName) \(criterion.directionLabel(ascending: ascending))\(isActive ? ", selected" : "")")
    }
}

// MARK: - Private

private extension SortSheet {
    func criterionSection(_ criterion: SortCriterion) -> some View {
        SectionCard {
            SortRow(
                criterion: criterion,
                ascending: true,
                isActive: isActive(criterion: criterion, ascending: true),
                action: { selectSort(criterion: criterion, ascending: true) }
            )

            sectionDivider

            SortRow(
                criterion: criterion,
                ascending: false,
                isActive: isActive(criterion: criterion, ascending: false),
                action: { selectSort(criterion: criterion, ascending: false) }
            )
        }
    }

    var sectionDivider: some View {
        Rectangle()
            .fill(Design.Colors.separator)
            .frame(height: 1)
            .padding(.horizontal)
    }

    func isActive(criterion: SortCriterion, ascending: Bool) -> Bool {
        fileStore.sortOrder.criterion == criterion && fileStore.sortOrder.ascending == ascending
    }

    func selectSort(criterion: SortCriterion, ascending: Bool) {
        fileStore.sortOrder.criterion = criterion
        fileStore.sortOrder.ascending = ascending
        fileStore.resort()
        dismiss()
    }
}

#Preview {
    SortSheet()
        .presentationDetents([.medium])
        .presentationBackground(Design.Colors.background)
        .environment(FileStore())
}
