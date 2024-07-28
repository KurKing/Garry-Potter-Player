//
//  SpeedButtonView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct SpeedButtonView: View {
    
    let store: StoreOf<SpeedReducer>
    
    var body: some View {
        
        Button(action: {
            store.send(.speedButtonTapped)
        }) {
            
            Text(speedString)
                .font(.title3)
                .foregroundStyle(Color(uiColor: .darkGray))
                .frame(width: 150, alignment: .center)
                .padding(.vertical)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
    
    private var speedString: String {
        
        // %.2f for speed like 0.75
        var string = String(format: "Speed %.2f", store.currentSpeed)
        
        // handle cases when %.1f actually needed
        if string.last == "0" { string.removeLast() }
        
        return string + "x"
    }
}

#Preview {
    SpeedButtonView(store: SpeedReducer.previewStore)
}
