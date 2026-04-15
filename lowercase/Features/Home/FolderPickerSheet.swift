import SwiftUI

enum FolderPickerMode {
    case addNote
    case move(url: URL)
}

struct FolderPickerSheet: View {
    let mode: FolderPickerMode
    var onNoteCreated: ((URL, String) -> Void)?

    @Environment(FileStore.self) private var fileStore
    @Environment(\.dismiss) private var dismiss
    @State private var newFolderName = ""
    @State private var isEditingNewFolder = false
    @FocusState private var isTextFieldFocused: Bool
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    PickerRootRow(action: selectRoot)

                    NewFolderRow(
                        name: $newFolderName,
                        isEditing: $isEditingNewFolder,
                        isFocused: $isTextFieldFocused,
                        onSubmit: submitNewFolder
                    )

                    ForEach(folders, id: \.url) { folder in
                        PickerFolderRow(name: folder.name, depth: folder.depth) {
                            selectFolder(at: folder.url)
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.contentMargin)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Design.Colors.background)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text(title)
                        .font(.geistPixel)
                        .foregroundStyle(Design.Colors.secondaryLabel)
                }
                
                ToolbarItem(placement:. topBarTrailing) {
                    if isEditingNewFolder {
                        doneButton
                            .glassEffectID("trailingAction", in: namespace)
                    } else {
                        closeButton
                            .glassEffectID("trailingAction", in: namespace)
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .presentationBackground(Design.Colors.background)
    }
}

// MARK: - Subviews

private struct PickerRootRow: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.labelGap) {
                Icon.slash.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.accent)

                Text("root")
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.accent)

                Spacer()
            }
            .frame(minHeight: Design.Sizing.minRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Root folder")
    }
}

private struct NewFolderRow: View {
    @Binding var name: String
    @Binding var isEditing: Bool
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void

    var body: some View {
        Button {
            withAnimation {
                isEditing = true
            }
            isFocused.wrappedValue = true
        } label: {
            HStack(spacing: Design.Spacing.labelGap) {
                Icon.plusCircle.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.accent)

                if isEditing {
                    TextField(
                        "",
                        text: $name,
                        prompt: Text("folder name")
                            .foregroundStyle(Design.Colors.tertiaryLabel)
                    )
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.accent)
                    .focused(isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit(onSubmit)
                } else {
                    Text("new folder")
                        .font(.geistPixel)
                        .foregroundStyle(Design.Colors.accent)
                }

                Spacer()
            }
            .frame(minHeight: Design.Sizing.minRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New folder")
    }
}

private struct PickerFolderRow: View {
    let name: String
    let depth: Int
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.labelGap) {
                HStack(spacing: Design.Spacing.iconGap) {
                    ForEach(0..<depth, id: \.self) { _ in
                        Color.clear
                            .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    }

                    Icon.folderClosed.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                        .foregroundStyle(Design.Colors.secondaryAccent)
                }

                Text(name)
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.label)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Icon.chevronRight.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.tertiaryLabel)
            }
            .frame(minHeight: Design.Sizing.minRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Folder: \(name)")
    }
}

// MARK: - Private

private extension FolderPickerSheet {
    var title: String {
        switch mode {
        case .addNote: "Add note to..."
        case .move: "Move to..."
        }
    }

    var excludedURL: URL? {
        switch mode {
        case .addNote: nil
        case .move(let url): url
        }
    }

    var folders: [(url: URL, name: String, depth: Int)] {
        fileStore.allFolders(excluding: excludedURL)
    }

    var closeButton: some View {
        Button { dismiss() } label: {
            Icon.cross.image
                .resizable()
                .scaledToFit()
                .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                .foregroundStyle(Design.Colors.label)
        }
//        .glassEffectID("close", in: namespace)
    }

    var doneButton: some View {
        Button(action: submitNewFolder) {
            Text("Done")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)
        }
        .buttonStyle(.glassProminent)
        .tint(Design.Colors.glassTint)
//        .glassEffectID("done", in: namespace)
    }

    // MARK: - Actions

    func selectRoot() {
        Task {
            do {
                switch mode {
                case .addNote:
                    let url = try await fileStore.createNote(in: nil)
                    let name = url.deletingPathExtension().lastPathComponent
                    onNoteCreated?(url, name)
                case .move(let sourceURL):
                    guard let root = await fileStore.resolveRootURL() else {
                        fileStore.currentError = .rootUnavailable
                        return
                    }
                    try await fileStore.moveItem(at: sourceURL, to: root)
                }
                dismiss()
            } catch let error as FileError {
                fileStore.currentError = error
            } catch {}
        }
    }

    func selectFolder(at folderURL: URL) {
        Task {
            do {
                switch mode {
                case .addNote:
                    let url = try await fileStore.createNote(in: folderURL)
                    let name = url.deletingPathExtension().lastPathComponent
                    onNoteCreated?(url, name)
                case .move(let sourceURL):
                    try await fileStore.moveItem(at: sourceURL, to: folderURL)
                }
                dismiss()
            } catch let error as FileError {
                fileStore.currentError = error
            } catch {}
        }
    }

    func submitNewFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isTextFieldFocused = false

        Task {
            do {
                let folderURL = try await fileStore.createFolder(named: trimmed)

                switch mode {
                case .addNote:
                    let url = try await fileStore.createNote(in: folderURL)
                    let name = url.deletingPathExtension().lastPathComponent
                    onNoteCreated?(url, name)
                case .move(let sourceURL):
                    try await fileStore.moveItem(at: sourceURL, to: folderURL)
                }
                dismiss()
            } catch let error as FileError {
                fileStore.currentError = error
            } catch {}
        }
    }
}

#Preview {
    FolderPickerSheet(mode: .addNote)
        .environment(FileStore())
}
