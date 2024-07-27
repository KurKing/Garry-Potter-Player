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
        fileprivate var isUpdatingTime = false
        fileprivate var wasPlayingOnTimeUpdate = false

        var chapterNumber = 1
        let totalChapters = 1
        let title = "Harry Potter"
        
        var currentTime: TimeInterval = 0
        var totalTime: TimeInterval = 0
        
        // Speed
        var currentSpeed: Double = 1.0
        fileprivate var currentSpeedIndex = 2 {
            didSet {
                currentSpeed = speeds[currentSpeedIndex]
            }
        }
        fileprivate let speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
        
        init(player: any BookPlayer) {
            
            _player = Shared(wrappedValue: player, .inMemory("book.player"))
            
            totalTime = player.duration
        }
        
        // Equatable
        private let id = UUID()
        static func == (lhs: PlayerFeature.State, rhs: PlayerFeature.State) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Action {
        
        case updateTime
        case timeStartUpdating
        case timeChanged(TimeInterval)
        case timeStopUpdating
        case forceTimeUpdate(TimeInterval)
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
            case let .forceTimeUpdate(time):
                
                state.currentTime = time
                state.player.currentTime = time
                return .none
            case let .audioControlButtonTapped(action):
                
                if action == .play, !state.isPlaying {
                    return .concatenate(
                        .run { @MainActor send in
                            while true {
                                try await self.clock.sleep(for: .seconds(1))
                                send(.updateTime)
                            }
                        }.cancellable(id: "onTapPlay", cancelInFlight: true),
                        
                        self.handleAudioControl(state: &state, action: action)
                    )
                } else {
                    return handleAudioControl(state: &state, action: action)
                }
            case .speedButtonTapped:
                
                state.currentSpeedIndex = (state.currentSpeedIndex + 1) % state.speeds.count
                state.player.set(speed: state.currentSpeed)
                return .none
            case .updateTime:
                
                if !state.isUpdatingTime, state.isPlaying {
                    state.currentTime = state.player.currentTime
                }
                return .none
            case .timeStartUpdating:
                
                state.isUpdatingTime = true
                state.wasPlayingOnTimeUpdate = state.isPlaying
                state.player.pause()
                state.isPlaying = state.player.isPlaying
                return .none
            case .timeStopUpdating:
                                
                state.player.currentTime = state.currentTime
                
                if state.wasPlayingOnTimeUpdate {
                    state.player.play()
                    state.isPlaying = state.player.isPlaying
                }
                
                state.isUpdatingTime = false

                return .none
            }
        }
    }
    
    private func handleAudioControl(state: inout State,
                                    action: AudioControlAction) -> Effect<Action> {
        
        let currentTime = state.currentTime
        
        switch action {
        case .play:
            if state.isPlaying {
                state.player.pause()
            } else {
                state.player.play()
            }
            state.isPlaying = state.player.isPlaying
            return .none
        case .goBackward:
            return .run { send in
                await send(.forceTimeUpdate(currentTime - 5))
            }
        case .goForward:
            return .run { send in
                await send(.forceTimeUpdate(currentTime + 10))
            }
        case .previousChapter:
            return .none
        case .nextChapter:
            return .none
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
