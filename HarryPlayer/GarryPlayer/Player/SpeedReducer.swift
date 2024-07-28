//
//  SpeedReducer.swift
//  GarryPlayer
//
//  Created by Oleksii on 28.07.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SpeedReducer {
    
    private static var speeds: [Double] { [0.5, 0.75, 1.0, 1.25, 1.5, 2.0] }
    
    @ObservableState
    struct State: Equatable {
        
        fileprivate var player: any BookPlayer

        var currentSpeed: Double = 1.0
        fileprivate var currentSpeedIndex = 2
        
        init(player: any BookPlayer) {
            self.player = player
        }
        
        // Equatable
        static func == (lhs: SpeedReducer.State, rhs: SpeedReducer.State) -> Bool {
            lhs.currentSpeed == rhs.currentSpeed
        }
    }
    
    enum Action {
        case speedButtonTapped
    }
    
    @Dependency(\.continuousClock) var clock
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case .speedButtonTapped:
                
                let speeds = Self.speeds
                
                let speedIndex = (state.currentSpeedIndex + 1) % speeds.count
                state.currentSpeedIndex = speedIndex
                
                state.currentSpeed = speeds[speedIndex]
                state.player.speed = state.currentSpeed
                
                return .none
            }
        }
    }
}
