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
    
    @ObservableState
    struct State: Equatable {
        
        var currentSpeed: Double = 1.0
        fileprivate var currentSpeedIndex = 2 {
            didSet {
                currentSpeed = speeds[currentSpeedIndex]
            }
        }
        fileprivate let speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    }
    
    enum Action {
        case speedButtonTapped
        case setSpeed(Double)
    }
    
    @Dependency(\.continuousClock) var clock
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
                
            switch action {
            case .speedButtonTapped:
                
                let speedIndex = (state.currentSpeedIndex + 1) % state.speeds.count
                state.currentSpeedIndex = speedIndex
                
                let speed = state.speeds[speedIndex]
                
                return .run { send in
                    await send(.setSpeed(speed))
                }
            case .setSpeed(_):
                return .none
            }
        }
    }
}
