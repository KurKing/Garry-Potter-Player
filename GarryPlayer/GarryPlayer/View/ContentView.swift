//
//  ContentView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    let store: StoreOf<PlayerFeature>
    
    var body: some View {
        
        BookCoverView(store: store)
    }
}

#Preview {
    ContentView(store: PlayerFeature.previewStore)
}
