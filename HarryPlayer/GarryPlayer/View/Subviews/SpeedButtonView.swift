//
//  SpeedButtonView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct SpeedButtonView: View {
    
    let store: StoreOf<PlayerFeature>
    
    var body: some View {
        
        Button(action: {
            store.send(.speedButtonTapped)
        }) {
            
            Text(String(format: "Speed %.1fx", store.currentSpeed))
                .font(.title3)
                .foregroundStyle(Color(uiColor: .darkGray))
                .frame(width: 120, alignment: .center)
                .padding(.vertical)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}

#Preview {
    SpeedButtonView(store: PlayerFeature.previewStore)
}
