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
        
        @Shared fileprivate var player: any BookPlayer

        var isPlaying = false

        var chapterNumber = 1
        var totalChapters = 1
        let title = "Harry Potter"
        
        var currentTime: TimeInterval = 0
        var totalTime: TimeInterval = 0
        
        // Speed
        var currentSpeed: Double = 1.0
        fileprivate var currentSpeedIndex = 1 {
            didSet {
                currentSpeed = speeds[currentSpeedIndex]
            }
        }
        fileprivate let speeds = [0.5, 1.0, 2.0, 2.5]
        
        init(player: any BookPlayer) {
            
            _player = Shared(wrappedValue: player, .inMemory("book.player"))
            
            totalTime = player.duration
            totalChapters = player.filesAmount
        }
        
        // Equatable
        private let id = UUID()
        static func == (lhs: PlayerFeature.State, rhs: PlayerFeature.State) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Action {
        
        case timeChanged(TimeInterval)
        case speedButtonTapped
        case audioControlButtonTapped(AudioControlAction)
    }
    
    @Dependency(\.continuousClock) var clock
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
                
            switch action {
            case let .timeChanged(time):
                
                state.currentTime = time
                return .none
            case let .audioControlButtonTapped(action):
                
                if action == .play {
                    state.player.play()
                    state.isPlaying = state.player.isPlaying
                } else {
                    print("\(action) tapped")
                }
                return .none
            case .speedButtonTapped:
                
                state.currentSpeedIndex = (state.currentSpeedIndex + 1) % state.speeds.count
                return .none
            }
        }
    }
}

extension PlayerFeature {
    
    static var storeInstance: StoreOf<PlayerFeature> {
        
        Store(initialState: PlayerFeature.State(player: AVBookPlayer()),
              reducer: { PlayerFeature() })
    }
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<PlayerFeature> { storeInstance }
}
