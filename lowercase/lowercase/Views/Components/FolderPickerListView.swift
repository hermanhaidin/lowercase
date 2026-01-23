import SwiftUI

struct FolderPickerListView: View {
    @Binding var isCreatingFolder: Bool
    @Binding var newFolderName: String
    @FocusState.Binding var isFolderNameFocused: Bool
    let folders: [Folder]
    let currentFolderURL: URL?
    let gapWidth: CGFloat
    let indentWidth: CGFloat
    let folderIconWidth: CGFloat
    let showsCurrentLabel: Bool
    let disableCurrentSelection: Bool
    let onSubmit: () -> Void
    let onSelectFolder: (Folder) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isCreatingFolder {
                    FolderNameInputRow(
                        name: $newFolderName,
                        onSubmit: onSubmit,
                        isFocused: $isFolderNameFocused
                    )
                } else {
                    Button {
                        isCreatingFolder = true
                    } label: {
                        HStack(spacing: gapWidth) {
                            Image(systemName: "plus")
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                                .frame(width: folderIconWidth)
                            
                            Text("new folder")
                                .foregroundStyle(.tint)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(folders) { folder in
                    FolderPickerTreeView(
                        folder: folder,
                        depth: 0,
                        currentFolderURL: currentFolderURL,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        iconLeadingPadding: 0,
                        rowPadding: EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8),
                        showsChevron: true,
                        showsCurrentLabel: showsCurrentLabel,
                        disableCurrentSelection: disableCurrentSelection,
                        hidesRowSeparators: false,
                        onSelect: onSelectFolder
                    )
                }
            }
        }
        .monospaced()
        .contentMargins(.leading, 20)
        .contentMargins([.top, .trailing, .bottom], 16)
        .scrollBounceBehavior(.basedOnSize)
    }
}
