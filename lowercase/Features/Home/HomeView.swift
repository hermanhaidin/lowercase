import SwiftUI

struct HomeView: View {
    @Environment(FileStore.self) private var fileStore
    @State private var path: [HomeDestination] = []
    @State private var showStorageSwitcher = false
    @State private var showSortSheet = false
    @State private var quickActionTarget: FlatTreeRow?

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if fileStore.isEmpty {
                    HomeEmptyView()
                } else {
                    FolderTreeView(
                        onQuickAction: { quickActionTarget = $0 },
                        onTapFile: { path.append(.editor(url: $0.id, name: $0.name)) }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    storageSwitcherButton
                }
            }
            .safeAreaBar(edge: .bottom) {
                HomeBottomBar(
                    allExpanded: fileStore.allExpanded,
                    isEmpty: fileStore.isEmpty,
                    onToggleExpansion: toggleExpansion,
                    onSort: { showSortSheet = true },
                    onAdd: addNote
                )
            }
            .sheet(isPresented: $showStorageSwitcher) {
                StorageSwitcherSheet()
                    .presentationDetents([.height(160)])
                    .presentationBackground(Design.Colors.background)
            }
            .sheet(isPresented: $showSortSheet) {
                SortSheet()
                    .presentationDetents([.medium])
                    .presentationBackground(Design.Colors.background)
            }
            .sheet(item: $quickActionTarget) { row in
                QuickActionsSheet(row: row)
                    .presentationDetents([.medium])
                    .presentationBackground(Design.Colors.background)
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
            HStack(spacing: 6) {
                Text(rootName)
                    .font(.geistPixel)

                Icon.chevronUpDown.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Sizing.iconSize, height: Design.Sizing.iconSize)
            }
        }
        .buttonStyle(.glass)
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
        // No-op for Phase 3 — add note sheet will be built in a future phase
    }
}

#Preview {
    HomeView()
        .environment(FileStore())
}
