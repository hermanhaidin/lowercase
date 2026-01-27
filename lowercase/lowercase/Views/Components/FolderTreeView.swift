import SwiftUI

struct FolderTreeView: View {
    let folder: Folder
    let depth: Int
    let folderGapWidth: CGFloat
    let noteGapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let folderIconWidth: CGFloat
    let noteIconWidth: CGFloat
    let isExpanded: (URL) -> Bool
    let onToggleExpanded: (URL) -> Void
    let onFolderLongPress: (Folder) -> Void
    let onNoteLongPress: (Note) -> Void
    let renameTarget: RenameTarget?
    @Binding var renameText: String
    @FocusState.Binding var isRenameFocused: Bool
    let onSubmitRename: () -> Void
    let allowLongPress: Bool
    
    var body: some View {
        Group {
            if isRenaming(folder) {
                FolderNameInputRow(
                    name: $renameText,
                    depth: depth,
                    gapWidth: folderGapWidth,
                    chevronIconWidth: chevronIconWidth,
                    folderIconWidth: folderIconWidth,
                    onSubmit: onSubmitRename,
                    isFocused: $isRenameFocused
                )
                .id(folder.url)
            } else {
                let row = FolderRow(
                    folder: folder,
                    depth: depth,
                    gapWidth: folderGapWidth,
                    chevronIconWidth: chevronIconWidth,
                    folderIconWidth: folderIconWidth,
                    isExpanded: isExpanded(folder.url),
                    onToggleExpanded: { onToggleExpanded(folder.url) }
                )
                
                if allowLongPress {
                    row.simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.4)
                            .onEnded { _ in onFolderLongPress(folder) }
                    )
                } else {
                    row
                }
            }
            
            if isExpanded(folder.url) {
                LazyVStack(spacing: 0) {
                    ForEach(folder.notes) { note in
                        if isRenaming(note) {
                            NoteNameInputRow(
                                name: $renameText,
                                depth: depth + 1,
                                isOrphan: false,
                                gapWidth: noteGapWidth,
                                chevronIconWidth: chevronIconWidth,
                                noteIconWidth: noteIconWidth,
                                onSubmit: onSubmitRename,
                                isFocused: $isRenameFocused
                            )
                            .id(note.url)
                        } else {
                            let row = NavigationLink(value: AppRoute.editor(note)) {
                                NoteRow(
                                    note: note,
                                    depth: depth + 1,
                                    isOrphan: false,
                                    gapWidth: noteGapWidth,
                                    chevronIconWidth: chevronIconWidth,
                                    noteIconWidth: noteIconWidth
                                )
                            }
                            .buttonStyle(.plain)
                            
                            if allowLongPress {
                                row.simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.4)
                                        .onEnded { _ in onNoteLongPress(note) }
                                )
                            } else {
                                row
                            }
                        }
                    }
                    
                    ForEach(folder.subfolders) { subfolder in
                        FolderTreeView(
                            folder: subfolder,
                            depth: depth + 1,
                            folderGapWidth: folderGapWidth,
                            noteGapWidth: noteGapWidth,
                            chevronIconWidth: chevronIconWidth,
                            folderIconWidth: folderIconWidth,
                            noteIconWidth: noteIconWidth,
                            isExpanded: isExpanded,
                            onToggleExpanded: onToggleExpanded,
                            onFolderLongPress: onFolderLongPress,
                            onNoteLongPress: onNoteLongPress,
                            renameTarget: renameTarget,
                            renameText: $renameText,
                            isRenameFocused: $isRenameFocused,
                            onSubmitRename: onSubmitRename,
                            allowLongPress: allowLongPress
                        )
                    }
                }
            }
        }
    }
    
    private func isRenaming(_ folder: Folder) -> Bool {
        guard case .folder(let url) = renameTarget else { return false }
        return url == folder.url
    }
    
    private func isRenaming(_ note: Note) -> Bool {
        guard case .note(let url) = renameTarget else { return false }
        return url == note.url
    }
}
