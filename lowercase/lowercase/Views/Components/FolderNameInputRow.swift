import SwiftUI

struct FolderNameInputRow: View {
    @Binding var name: String
    var placeholder = "folder name"
    var onSubmit: () -> Void
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $name)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($isFocused)
            .onSubmit { onSubmit() }
    }
}
