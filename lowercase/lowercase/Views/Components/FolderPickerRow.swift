import SwiftUI

struct FolderPickerRow: View {
    let folder: Folder
    let depth: Int
    let isCurrent: Bool
    let showsCurrentLabel: Bool
    let showsChevron: Bool
    let gapWidth: CGFloat
    let indentWidth: CGFloat
    let iconWidth: CGFloat
    let iconLeadingPadding: CGFloat
    let rowPadding: EdgeInsets
    let isDisabled: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: gapWidth) {
                if depth > 0 {
                    Spacer()
                        .frame(width: CGFloat(depth) * indentWidth)
                }
                
                Image(systemName: "folder.fill")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.blue.gradient)
                    .frame(width: iconWidth, height: iconWidth)
                    .padding(.leading, iconLeadingPadding)
                
                Text(folder.name)
                    .foregroundStyle(isCurrent ? .secondary : .primary)
                    .lineLimit(1)
                
                Spacer()
                
                if showsCurrentLabel && isCurrent {
                    Text("current")
                        .foregroundStyle(.secondary)
                } else if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(rowPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
