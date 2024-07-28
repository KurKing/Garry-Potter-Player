//
//  ContentView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    let store: StoreOf<PlayerReducer>
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 24) {
                
                BookCoverView(store: store)
                
                TimeSliderView(store: store)
                
                SpeedButtonView(store: store)
                
                PlayingButtonsView(store: store)
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.top, 0)
            .safeAreaPadding(.bottom, 20)
            .frame(minWidth: 0, maxWidth: 650)
        }
    }
}

#Preview {
    ContentView(store: PlayerReducer.previewStore)
}
