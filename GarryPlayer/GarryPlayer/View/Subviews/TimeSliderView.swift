//
//  TimeSliderView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct TimeSliderView: View {
    
    let store: StoreOf<PlayerFeature>
    
    var body: some View {
        
        HStack {
            
            Text(store.currentTime.formattedString)
            
            WithViewStore(store, observe: { $0 }) { viewStore in
                
                Slider(
                    value: viewStore.binding(
                        get: { $0.currentTime },
                        send: PlayerFeature.Action.timeChanged
                    ),
                    in: 0...viewStore.totalTime
                )
            }
            
            Text(store.totalTime.formattedString)
        }
    }
}

fileprivate extension TimeInterval {
    
    var formattedString: String {
        
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        
        return .init(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TimeSliderView(store: PlayerFeature.previewStore)
}
