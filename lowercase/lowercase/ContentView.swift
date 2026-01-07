//
//  ContentView.swift
//  lowercase
//
//  Created by Herman Haidin on 02.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var folderName = ""
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            // Custom pixel font
            Text("this is a custom pixel font")
                .font(.custom("MonacoTTF", size: 18, relativeTo: .body))
            
            TextField("folder name", text: $folderName)
                .font(.custom("MonacoTTF", size: 18, relativeTo: .body))
                
            Button {
                // Do nothing, this is a text
            } label: {
                Text("Settings")
//                    .font(.custom("MonacoTTF", size: 18))
//                    .monospaced()
            }
            .buttonStyle(.glassProminent)
            
            Button {
                // Do nothing, this is a text
            } label: {
                Text("Close")
//                    .font(.custom("MonacoTTF", size: 18))
//                    .monospaced()
            }
            .buttonStyle(.glass)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
