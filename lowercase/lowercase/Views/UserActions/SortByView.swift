import SwiftUI

struct SortByView: View {
    let selectedOption: SortOption
    let onSelect: (SortOption) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SortOptionButton(
                        option: .nameAsc,
                        selectedOption: selectedOption,
                        title: "name",
                        detail: "a to z",
                        onSelect: onSelect
                    )
                    SortOptionButton(
                        option: .nameDesc,
                        selectedOption: selectedOption,
                        title: "name",
                        detail: "z to a",
                        onSelect: onSelect
                    )
                }
                
                Section {
                    SortOptionButton(
                        option: .modifiedDesc,
                        selectedOption: selectedOption,
                        title: "modified",
                        detail: "new to old",
                        onSelect: onSelect
                    )
                    SortOptionButton(
                        option: .modifiedAsc,
                        selectedOption: selectedOption,
                        title: "modified",
                        detail: "old to new",
                        onSelect: onSelect
                    )
                }
                
                Section {
                    SortOptionButton(
                        option: .createdDesc,
                        selectedOption: selectedOption,
                        title: "created",
                        detail: "new to old",
                        onSelect: onSelect
                    )
                    SortOptionButton(
                        option: .createdAsc,
                        selectedOption: selectedOption,
                        title: "created",
                        detail: "old to new",
                        onSelect: onSelect
                    )
                }
            }
            .monospaced()
            .listSectionSpacing(ViewTokens.sheetSectionSpacing)
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    SortByView(selectedOption: .modifiedDesc) { _ in }
}
