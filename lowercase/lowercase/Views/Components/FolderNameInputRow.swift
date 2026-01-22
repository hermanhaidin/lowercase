import SwiftUI

struct FolderNameInputRow: View {
    @Binding var name: String
    var placeholder = "folder name"
    var createTitle = "create"
    var onSubmit: () -> Void
    var onCreate: () -> Void
    @FocusState.Binding var isFocused: Bool
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        HStack(spacing: ViewTokens.folderRowGap) {
            TextField(placeholder, text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .onSubmit { onSubmit() }
            
            Button(createTitle) { onCreate() }
                .disabled(trimmedName.isEmpty)
        }
    }
}
