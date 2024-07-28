//
//  PlayerReducer.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation
import ComposableArchitecture
import Combine

@Reducer
struct PlayerReducer {
    
    @ObservableState
    struct State: Equatable {
        
        var isPlaying = false
        
        var chapterNumber = 1
        let totalChapters = 1
        let title = "Harry Potter"

        var speedState: SpeedReducer.State
        var timeState: TimeReducer.State
        
        fileprivate var player: any BookPlayer
                
        init(player: any BookPlayer) {
            
            self.player = player
                        
            speedState = SpeedReducer.State(player: player)
            timeState = TimeReducer.State(player: player)
        }
        
        // Equatable
        private let id = UUID()
        static func == (lhs: PlayerReducer.State, rhs: PlayerReducer.State) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Action {
        
        case isPlayingUpdated
        
        case audioControlButtonTapped(AudioControlAction)
        case time(TimeReducer.Action)
        case speed(SpeedReducer.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    var body: some ReducerOf<Self> {
        
        CombineReducers {
            
            Scope(state: \.speedState, action: \.speed) {
                SpeedReducer()
            }
            
            Scope(state: \.timeState, action: \.time) {
                TimeReducer()
            }
            
            Reduce { state, action in
                
                switch action {
                case let .audioControlButtonTapped(action):
                    return handleAudioControl(state: &state, action: action)
                case .isPlayingUpdated:
                    state.isPlaying = state.player.isPlaying
                default:
                    break
                }
                return .none
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
                        send(.time(.updateTime))
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
        
        let currentTime = state.timeState.currentTime
        
        switch action {
        case .play:
            
            if state.isPlaying {
                state.player.pause()
            } else {
                state.player.play()
            }
            return .none
        case .goBackward:
            return .run { send in
                await send(.time(.forceTimeUpdate(currentTime - 5)))
            }
        case .goForward:
            return .run { send in
                await send(.time(.forceTimeUpdate(currentTime + 10)))
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
        
        let store = Store(initialState: PlayerReducer.State(player: player!),
                          reducer: { PlayerReducer() })
        
        player?.isPlayingUpdated = { [weak store] in
            store?.send(.isPlayingUpdated)
        }
        
        return store
    }
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<PlayerReducer> { storeInstance }
}
