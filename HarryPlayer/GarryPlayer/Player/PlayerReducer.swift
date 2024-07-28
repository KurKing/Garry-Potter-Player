//
//  PlayerReducer.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PlayerReducer {
    
    @ObservableState
    struct State: Equatable {
        
        fileprivate var player: any BookPlayer

        var isPlaying = false
        fileprivate var isUpdatingTime = false
        fileprivate var wasPlayingOnTimeUpdate = false

        var chapterNumber = 1
        let totalChapters = 1
        let title = "Harry Potter"
        
        var currentTime: TimeInterval = 0
        var totalTime: TimeInterval = 0
        
        var speedState: SpeedReducer.State
        
        init(player: any BookPlayer) {
                                    
            self.player = player
            
            totalTime = player.duration
            speedState = SpeedReducer.State(player: player)
        }
        
        // Equatable
        private let id = UUID()
        static func == (lhs: PlayerReducer.State, rhs: PlayerReducer.State) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Action {
        
        case updateTime
        case timeStartUpdating
        case timeChanged(TimeInterval)
        case timeStopUpdating
        case forceTimeUpdate(TimeInterval)
        case audioControlButtonTapped(AudioControlAction)
        
        case speed(SpeedReducer.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    var body: some ReducerOf<Self> {
        
        CombineReducers {
            
            Scope(state: \.speedState, action: \.speed) {
                SpeedReducer()
            }
            
            Reduce { state, action in
                
                switch action {
                case let .audioControlButtonTapped(action):
                    return handleAudioControl(state: &state, action: action)
                    
                case let .timeChanged(time):
                    
                    state.currentTime = time
                    return .none
                case let .forceTimeUpdate(time):
                    
                    state.currentTime = time
                    state.player.currentTime = time
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
                default:
                    return .none
                }
            }
        }
    }
}

// MARK: - Audio control
private extension PlayerReducer {
    
    func handleAudioControl(state: inout State,
                            action: AudioControlAction) -> Effect<Action> {
        
        if action == .play, !state.isPlaying {
            return .concatenate(
                .run { @MainActor send in
                    while true {
                        try await self.clock.sleep(for: .seconds(1))
                        send(.updateTime)
                    }
                }.cancellable(id: "onTapPlay", cancelInFlight: true),
                
                self.handleAudioControlInternal(state: &state, action: action)
            )
        } else {
            return handleAudioControlInternal(state: &state, action: action)
        }
    }
    
    private func handleAudioControlInternal(state: inout State,
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

// MARK: - Instantiate
extension PlayerReducer {
    
    static var storeInstance: StoreOf<PlayerReducer> {
        
        var player: (any BookPlayer)?
        
        if let fileName = AudioFilesNamesProvider().get.first,
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            player = AVBookPlayer(with: url)
        } else {
            fatalError("No mp3 files found.")
        }
        
        return Store(initialState: PlayerReducer.State(player: player!),
              reducer: { PlayerReducer() })
    }
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<PlayerReducer> { storeInstance }
}
