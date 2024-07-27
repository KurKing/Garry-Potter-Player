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
    struct State {

        var chapterNumber = 1
        let totalChapters = 4
        let title = "Harry Potter"
        
        var currentTime: TimeInterval = 0
        let totalTime: TimeInterval = 120
    }
    
    enum Action {
        
        case timeChanged(Double)
    }
    
//    var body: some ReducerOf<Self> {
//        
//        
//    }
}

extension PlayerFeature {
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<PlayerFeature> {
        
        Store(initialState: PlayerFeature.State(),
              reducer: {
            PlayerFeature()
        })
    }
}
