import SwiftUI

struct NoteNameInputRow: View {
    @Binding var name: String
    var placeholder = "note name"
    let depth: Int
    let isOrphan: Bool
    let gapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let noteIconWidth: CGFloat
    var onSubmit: () -> Void
    @FocusState.Binding var isFocused: Bool
    
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
            
            TextField(placeholder, text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .onSubmit { onSubmit() }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
