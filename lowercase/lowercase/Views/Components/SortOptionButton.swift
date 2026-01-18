import SwiftUI

struct SortOptionButton: View {
    let option: SortOption
    let selectedOption: SortOption
    let title: String
    let detail: String
    let onSelect: (SortOption) -> Void
    
    var body: some View {
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
