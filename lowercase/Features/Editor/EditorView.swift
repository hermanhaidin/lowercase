import SwiftUI

struct EditorView: View {
    let fileURL: URL
    let fileName: String

    var body: some View {
        Text("Editor placeholder")
            .font(.geistPixel)
            .foregroundStyle(Design.Colors.secondaryLabel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.Colors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(fileName)
                        .font(.geistPixel)
                        .foregroundStyle(Design.Colors.label)
                }
            }
    }
}

#Preview {
    NavigationStack {
        EditorView(fileURL: URL(filePath: "/test.md"), fileName: "test")
    }
}
