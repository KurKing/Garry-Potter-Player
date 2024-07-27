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
        
        VStack(alignment: .center, spacing: 20) {
            
            BookCoverView(store: store)

            TimeSliderView(store: store)
            
            PlayingButtonsView(store: store)
        }
        .padding(.horizontal, 20)
        .safeAreaPadding(.top, 0)
        .safeAreaPadding(.bottom, 20)
        .background(Color.white)
        .frame(minWidth: 0, maxWidth: 650)
    }
}

#Preview {
    ContentView(store: PlayerFeature.previewStore)
}
