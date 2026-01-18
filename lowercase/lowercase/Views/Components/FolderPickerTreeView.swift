import SwiftUI

struct FolderPickerTreeView: View {
    let folder: Folder
    let depth: Int
    let currentFolderURL: URL?
    let gapWidth: CGFloat
    let indentWidth: CGFloat
    let folderIconWidth: CGFloat
    let iconLeadingPadding: CGFloat
    let rowPadding: EdgeInsets
    let showsChevron: Bool
    let showsCurrentLabel: Bool
    let disableCurrentSelection: Bool
    let hidesRowSeparators: Bool
    let onSelect: (Folder) -> Void
    
    private var isCurrentFolder: Bool {
        guard let currentFolderURL else { return false }
        return folder.url == currentFolderURL
    }
    
    var body: some View {
        Group {
            FolderPickerRow(
                folder: folder,
                depth: depth,
                isCurrent: isCurrentFolder,
                showsCurrentLabel: showsCurrentLabel,
                showsChevron: showsChevron,
                gapWidth: gapWidth,
                indentWidth: indentWidth,
                iconWidth: folderIconWidth,
                iconLeadingPadding: iconLeadingPadding,
                rowPadding: rowPadding,
                isDisabled: disableCurrentSelection && isCurrentFolder,
                onSelect: { onSelect(folder) }
            )
            .listRowSeparator(hidesRowSeparators ? .hidden : .automatic)
            
            if !folder.subfolders.isEmpty {
                ForEach(folder.subfolders) { subfolder in
                    FolderPickerTreeView(
                        folder: subfolder,
                        depth: depth + 1,
                        currentFolderURL: currentFolderURL,
                        gapWidth: gapWidth,
                        indentWidth: indentWidth,
                        folderIconWidth: folderIconWidth,
                        iconLeadingPadding: iconLeadingPadding,
                        rowPadding: rowPadding,
                        showsChevron: showsChevron,
                        showsCurrentLabel: showsCurrentLabel,
                        disableCurrentSelection: disableCurrentSelection,
                        hidesRowSeparators: hidesRowSeparators,
                        onSelect: onSelect
                    )
                }
            }
        }
    }
}
