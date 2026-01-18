import SwiftUI

struct StorageSwitcherView: View {
    let selectedRoot: StorageRoot
    let onSelectLocal: () -> Void
    let onOpenSettings: () -> Void
    
    @ScaledMetric private var gapWidth = ViewTokens.listRowIconGap
    @ScaledMetric private var iconSize = ViewTokens.folderRowIconSize
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    StorageOptionButton(
                        systemImage: "iphone",
                        title: "on my iphone",
                        gapWidth: gapWidth,
                        iconWidth: iconSize,
                        isSelected: selectedRoot == .local,
                        showsCheckmark: true,
                        onSelect: onSelectLocal
                    )
                }
                
                Section {
                    QuickActionButton(
                        systemImage: "gearshape",
                        title: "settings",
                        gapWidth: gapWidth,
                        iconSize: iconSize,
                        role: nil,
                        action: onOpenSettings
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
