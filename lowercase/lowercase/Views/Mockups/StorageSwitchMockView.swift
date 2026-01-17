//
//  StorageSwitchMockView.swift
//  lowercase
//
//  Created by Herman Haidin on 17.01.2026.
//

import SwiftUI

struct StorageSwitchMockView: View {
    @ScaledMetric private var iconSize = 20.0
    
    var body: some View {
        NavigationStack {
            Form {
                // storage
                Section {
                    HStack {
                        Image(systemName: "iphone")
                            .frame(width: iconSize)
                        
                        Text("on my iphone")
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
                    }
                }
                
                // settings
                Section {
                    HStack {
                        Image(systemName: "gearshape")
                            .frame(width: iconSize)
                        
                        Text("settings")
                            .lineLimit(1)
                    }
                }
            }
            .listSectionSpacing(16)
            .monospaced()
        }
    }
}

#Preview {
    StorageSwitchMockView()
}
