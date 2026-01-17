import SwiftUI

struct StorageSwitcherSheetView: View {
    let selectedRoot: StorageRoot
    let onSelectLocal: () -> Void
    let onOpenSettings: () -> Void
    
    @ScaledMetric private var iconSize = 20.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        onSelectLocal()
                    } label: {
                        HStack {
                            Image(systemName: "iphone")
                                .frame(width: iconSize)
                            
                            Text("on my iphone")
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                            
                            if selectedRoot == .local {
                                Image(systemName: "checkmark")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Section {
                    Button {
                        onOpenSettings()
                    } label: {
                        HStack {
                            Image(systemName: "gearshape")
                                .frame(width: iconSize)
                            
                            Text("settings")
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .listSectionSpacing(16)
            .lcMonospaced()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StorageSwitcherSheetView(
        selectedRoot: .local,
        onSelectLocal: {},
        onOpenSettings: {}
    )
}
