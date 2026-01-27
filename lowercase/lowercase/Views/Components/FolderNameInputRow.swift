import SwiftUI

struct FolderNameInputRow: View {
    @Binding var name: String
    var placeholder = "folder name"
    let depth: Int
    let gapWidth: CGFloat
    let chevronIconWidth: CGFloat
    let folderIconWidth: CGFloat
    var onSubmit: () -> Void
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack(spacing: gapWidth) {
            if depth > 0 {
                Spacer()
                    .frame(width: CGFloat(depth) * chevronIconWidth)
            }
            
            Image(systemName: "chevron.right")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(width: chevronIconWidth)
                .hidden()
            
            Image(systemName: "folder.fill")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.blue.gradient)
                .frame(width: folderIconWidth, height: folderIconWidth)
            
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
