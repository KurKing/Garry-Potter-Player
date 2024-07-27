//
//  PlayerFeature.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PlayerFeature {
    
    @ObservableState
    struct State: Equatable {

        var isPlaying = false

        var chapterNumber = 1
        let totalChapters = 4
        let title = "Harry Potter"
        
        var currentTime: TimeInterval = 0
        let totalTime: TimeInterval = 120
    }
    
    enum Action {
        
        case timeChanged(TimeInterval)
        case audioControlButtonTapped(AudioControlAction)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
                
            switch action {
            case let .timeChanged(time):
                
                state.currentTime = time
                return .none
            case let .audioControlButtonTapped(action):
                
                if action == .play {
                    state.isPlaying.toggle()
                } else {
                    print("\(action) tapped")
                }
                return .none
            }
        }
    }
}

extension PlayerFeature {
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<PlayerFeature> {
        
        Store(initialState: PlayerFeature.State(),
              reducer: { PlayerFeature() })
    }
}
