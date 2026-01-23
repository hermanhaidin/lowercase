import SwiftUI

struct NoteRow: View {
    let note: Note
    let depth: Int
    let isOrphan: Bool
    let gapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let noteIconWidth: CGFloat
    
    var body: some View {
        HStack(spacing: gapWidth) {
            if isOrphan {
                Spacer()
                    .frame(width: chevronIconWidth)
            } else {
                Spacer()
                    .frame(width: CGFloat(depth) * chevronIconWidth)
                Spacer()
                    .frame(width: chevronIconWidth)
            }
            
            Image(systemName: "text.document")
                .font(.title3.weight(.medium))
                .symbolRenderingMode(.multicolor)
                .frame(width: noteIconWidth, height: noteIconWidth)
            
            Text(note.filename)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
