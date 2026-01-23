import SwiftUI

struct FolderNameInputRow: View {
    @Binding var name: String
    var placeholder = "folder name"
    let gapWidth: CGFloat
    let iconWidth: CGFloat
    let iconLeadingPadding: CGFloat
    let rowPadding: EdgeInsets
    var onSubmit: () -> Void
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack(spacing: gapWidth) {
            Image(systemName: "folder")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.blue.gradient)
                .frame(width: iconWidth, height: iconWidth)
                .padding(.leading, iconLeadingPadding)
            
            TextField(placeholder, text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .onSubmit { onSubmit() }
                .task { isFocused = true }
        }
        .padding(rowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
