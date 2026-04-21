import SwiftUI

struct EditorView: View {
    @Environment(FileStore.self) private var fileStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var fileURL: URL
    @State private var fileName: String

    @State private var content: String = ""
    @State private var isContentLoaded = false
    @State private var isEditorFocused = false
    @State private var wasJustCreated: Bool
    @State private var initialFileName: String
    @State private var autosaver = EditorAutosaver()

    @State private var quickActionTarget: FlatTreeRow?
    @State private var moveTarget: FlatTreeRow?
    @State private var pendingMoveTarget: FlatTreeRow?

    // Inline title rename
    @State private var isRenaming = false
    @State private var showDoneButton = false
    @State private var isTitleFieldFocused = false
    @State private var pendingRename = false
    @State private var renameDraft: String

    @Namespace private var namespace

    init(fileURL: URL, fileName: String, wasJustCreated: Bool = false) {
        _fileURL = State(initialValue: fileURL)
        _fileName = State(initialValue: fileName)
        _renameDraft = State(initialValue: fileName)
        _wasJustCreated = State(initialValue: wasJustCreated)
        _initialFileName = State(initialValue: fileName)
    }

    var body: some View {
        MarkdownTextView(
            text: $content,
            isFocused: $isEditorFocused,
            onChange: { newValue in
                autosaver.scheduleSave(content: newValue, to: fileURL, using: fileStore)
            }
        )
            .opacity(isContentLoaded ? 1 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.Colors.background.ignoresSafeArea())
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    ToolbarTextField(
                        text: $renameDraft,
                        isFocused: $isTitleFieldFocused,
                        isEditable: isRenaming,
                        onSubmit: submitRename
                    )
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if showDoneButton {
                        doneRenameButton
                            .glassEffectID("trailingAction", in: namespace)
                    } else {
                        moreButton
                            .glassEffectID("trailingAction", in: namespace)
                    }
                }
            }
            .sheet(item: $quickActionTarget, onDismiss: {
                if let target = pendingMoveTarget {
                    moveTarget = target
                    pendingMoveTarget = nil
                }
                if pendingRename {
                    pendingRename = false
                    renameDraft = fileName
                    isRenaming = true
                    isTitleFieldFocused = true
                }
            }) { row in
                QuickActionsSheet(
                    row: row,
                    onRename: { _ in pendingRename = true },
                    onMove: { pendingMoveTarget = $0 }
                )
                    .modifier(FittedPresentationModifier())
                    .presentationBackground(Design.Colors.background)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $moveTarget) { row in
                FolderPickerSheet(mode: .move(url: row.id))
            }
            .onChange(of: isTitleFieldFocused) { _, focused in
                if focused, isRenaming, !showDoneButton {
                    withAnimation {
                        showDoneButton = true
                    }
                } else if !focused, isRenaming {
                    submitRename()
                }
            }
            .onChange(of: isRenaming) { _, renaming in
                if renaming { isEditorFocused = false }
            }
            .task(id: fileURL) { await loadNote() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background || phase == .inactive {
                    autosaver.flushImmediate(content: content, to: fileURL, using: fileStore)
                }
            }
            .onDisappear(perform: handleDisappear)
    }
}

// MARK: - Subviews

private extension EditorView {
    var moreButton: some View {
        Button {
            quickActionTarget = FlatTreeRow(noteURL: fileURL, name: fileName)
        } label: {
            Label {
                Text("More actions")
            } icon: {
                Icon.moreHorizontal.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.label)
            }
            .labelStyle(.iconOnly)
        }
    }

    var doneRenameButton: some View {
        Button(action: submitRename) {
            Text("Done")
                .font(.geistPixel)
                .foregroundStyle(Design.Colors.label)
        }
        .buttonStyle(.glassProminent)
        .tint(Design.Colors.glassTint)
    }

    func handleDisappear() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let wasRenamed = fileName != initialFileName
        if wasJustCreated, trimmed.isEmpty, !wasRenamed {
            autosaver.cancelPending()
            let url = fileURL
            Task { try? await fileStore.trashItem(at: url) }
        } else {
            autosaver.flushImmediate(content: content, to: fileURL, using: fileStore)
        }
    }

    func loadNote() async {
        do {
            let loaded = try await fileStore.readNote(at: fileURL)
            autosaver.markLoaded(loaded)
            content = loaded
            isContentLoaded = true
            if wasJustCreated { isEditorFocused = true }
        } catch let error as FileError {
            fileStore.currentError = error
        } catch { }
    }

    func submitRename() {
        let trimmed = renameDraft.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty, trimmed != fileName else {
            isRenaming = false
            withAnimation { showDoneButton = false }
            isTitleFieldFocused = false
            renameDraft = fileName
            return
        }

        Task {
            do {
                let newURL = try await fileStore.rename(at: fileURL, to: trimmed)
                fileURL = newURL
                fileName = trimmed
            } catch let error as FileError {
                fileStore.currentError = error
            } catch {}
            isRenaming = false
            withAnimation { showDoneButton = false }
            isTitleFieldFocused = false
            renameDraft = fileName
        }
    }
}

#Preview {
    NavigationStack {
        EditorView(fileURL: URL(filePath: "/test.md"), fileName: "test")
    }
    .environment(FileStore())
}
