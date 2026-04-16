import SwiftUI

struct HomeView: View {
    @Environment(FileStore.self) private var fileStore
    @State private var path: [HomeDestination] = []
    @State private var showStorageSwitcher = false
    @State private var showSortSheet = false
    @State private var showAddNote = false
    @State private var quickActionTarget: FlatTreeRow?
    @State private var moveTarget: FlatTreeRow?
    @State private var pendingMoveTarget: FlatTreeRow?
    @State private var renameTarget: FlatTreeRow?
    @State private var pendingRenameTarget: FlatTreeRow?
    @State private var renameDraft = ""
    @FocusState private var isRenameFocused: Bool
    @State private var createdNote: (url: URL, name: String)?
    @Namespace private var namespace

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if fileStore.isEmpty {
                    HomeEmptyView()
                } else {
                    FolderTreeView(
                        renameTarget: $renameTarget,
                        renameDraft: $renameDraft,
                        renameFocused: $isRenameFocused,
                        onRenameSubmit: submitRename,
                        onQuickAction: { quickActionTarget = $0 },
                        onTapFile: { path.append(.editor(url: $0.id, name: $0.name)) }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.Colors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if renameTarget == nil {
                        storageSwitcherButton
                            .glassEffectID("leadingAction", in: namespace)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if renameTarget != nil {
                        doneRenameButton
                            .glassEffectID("trailingAction", in: namespace)
                    }
                }
            }
            .safeAreaBar(edge: .bottom) {
                HomeBottomBar(
                    allExpanded: fileStore.allExpanded,
                    onToggleExpansion: toggleExpansion,
                    onSort: { showSortSheet = true },
                    onAdd: addNote
                )
            }
            .sheet(isPresented: $showStorageSwitcher) {
                StorageSwitcherSheet()
                    .modifier(FittedPresentationModifier())
                    .presentationBackground(Design.Colors.background)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSortSheet) {
                SortSheet()
                    .modifier(FittedPresentationModifier())
                    .presentationBackground(Design.Colors.background)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $quickActionTarget, onDismiss: {
                if let target = pendingMoveTarget {
                    moveTarget = target
                    pendingMoveTarget = nil
                }
                if let target = pendingRenameTarget {
                    renameDraft = target.name
                    withAnimation {
                        renameTarget = target
                    }
                    pendingRenameTarget = nil
                }
            }) { row in
                QuickActionsSheet(
                    row: row,
                    onRename: { pendingRenameTarget = $0 },
                    onMove: { pendingMoveTarget = $0 }
                )
                    .modifier(FittedPresentationModifier())
                    .presentationBackground(Design.Colors.background)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddNote, onDismiss: {
                if let note = createdNote {
                    path.append(.editor(url: note.url, name: note.name))
                    createdNote = nil
                }
            }) {
                FolderPickerSheet(mode: .addNote) { url, name in
                    createdNote = (url, name)
                }
            }
            .sheet(item: $moveTarget) { row in
                FolderPickerSheet(mode: .move(url: row.id))
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .editor(let url, let name):
                    EditorView(fileURL: url, fileName: name)
                }
            }
            .task {
                try? await fileStore.loadTree()
            }
        }
    }
}

// MARK: - Subviews

private struct StorageSwitcherButton: View {
    let rootName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(rootName)
                    .font(.geistPixel)
                    .foregroundStyle(Design.Colors.label)

                Icon.chevronUpDown.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
                    .foregroundStyle(Design.Colors.tertiaryLabel)
            }
            .padding(.leading, Design.Spacing.toolbarItemGap)
        }
        .accessibilityLabel("Switch storage, currently \(rootName)")
    }
}

// MARK: - Private

private extension HomeView {
    var storageSwitcherButton: some View {
        StorageSwitcherButton(rootName: fileStore.activeRoot.shortName) {
            showStorageSwitcher = true
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

    func toggleExpansion() {
        withAnimation {
            if fileStore.allExpanded {
                fileStore.collapseAll()
            } else {
                fileStore.expandAll()
            }
        }
    }

    func addNote() {
        showAddNote = true
    }

    func submitRename() {
        guard let target = renameTarget else { return }
        let trimmed = renameDraft.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty, trimmed != target.name else {
            isRenameFocused = false
            withAnimation {
                renameTarget = nil
                renameDraft = ""
            }
            return
        }

        isRenameFocused = false

        Task {
            do {
                try await fileStore.rename(at: target.id, to: trimmed)
            } catch let error as FileError {
                fileStore.currentError = error
            } catch {}
            withAnimation {
                renameTarget = nil
                renameDraft = ""
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(FileStore())
}
