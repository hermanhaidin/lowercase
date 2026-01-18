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
    
    var body: some View {
        Group {
            FolderRow(
                folder: folder,
                depth: depth,
                gapWidth: folderGapWidth,
                chevronIconWidth: chevronIconWidth,
                folderIconWidth: folderIconWidth,
                isExpanded: isExpanded(folder.url),
                onToggleExpanded: { onToggleExpanded(folder.url) }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in onFolderLongPress(folder) }
            )
            
            if isExpanded(folder.url) {
                VStack(spacing: 0) {
                    ForEach(folder.notes) { note in
                        NavigationLink {
                            EditorView(note: note)
                        } label: {
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
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.4)
                                .onEnded { _ in onNoteLongPress(note) }
                        )
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
                            onNoteLongPress: onNoteLongPress
                        )
                    }
                }
            }
        }
    }
}
