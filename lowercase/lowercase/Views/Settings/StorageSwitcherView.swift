import SwiftUI

struct StorageSwitcherView: View {
    let selectedRoot: StorageRoot
    let onSelectLocal: () -> Void
    let onOpenSettings: () -> Void
    
    @ScaledMetric private var iconSize = ViewTokens.folderRowIconSize
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    StorageOptionButton(
                        systemImage: "iphone",
                        title: "on my iphone",
                        iconWidth: iconSize,
                        isSelected: selectedRoot == .local,
                        showsCheckmark: true,
                        onSelect: onSelectLocal
                    )
                }
                
                Section {
                    StorageOptionButton(
                        systemImage: "gearshape",
                        title: "settings",
                        iconWidth: iconSize,
                        isSelected: false,
                        showsCheckmark: false,
                        onSelect: onOpenSettings
                    )
                }
            }
            .listSectionSpacing(ViewTokens.sheetSectionSpacing)
            .monospaced()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StorageSwitcherView(
        selectedRoot: .local,
        onSelectLocal: {},
        onOpenSettings: {}
    )
}
