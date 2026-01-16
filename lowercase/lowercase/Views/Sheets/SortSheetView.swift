import SwiftUI

struct SortSheetView: View {
    let selectedOption: SortOption
    let onSelect: (SortOption) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    sortOptionRow(.nameAsc, title: "name:", detail: "a to z")
                    sortOptionRow(.nameDesc, title: "name:", detail: "z to a")
                }
                
                Section {
                    sortOptionRow(.modifiedDesc, title: "modified:", detail: "new to old")
                    sortOptionRow(.modifiedAsc, title: "modified:", detail: "old to new")
                }
                
                Section {
                    sortOptionRow(.createdDesc, title: "created:", detail: "new to old")
                    sortOptionRow(.createdAsc, title: "created:", detail: "old to new")
                }
            }
            .lcMonospaced()
            .listSectionSpacing(16)
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
    
    private func sortOptionRow(_ option: SortOption, title: String, detail: String) -> some View {
        Button {
            onSelect(option)
        } label: {
            HStack {
                Text(title)
                
                HStack {
                    Text(detail)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if option == selectedOption {
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SortSheetView(selectedOption: .modifiedDesc) { _ in }
}
