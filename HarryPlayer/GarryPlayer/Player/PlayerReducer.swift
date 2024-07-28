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
        var totalChapters: Int { chaptersNames.count }
        var isPreviousChapterAvailable: Bool { chapterNumber > 1 }
        var isNextChapterAvailable: Bool { chapterNumber < totalChapters }
        
        let title = "Harry Potter"

        var speedState: SpeedReducer.State
        var timeState: TimeReducer.State
        
        fileprivate var player: any BookPlayer
        fileprivate var chaptersNames: [String]
                
        init(player: any BookPlayer, chaptersNames: [String]) {
            
            self.player = player
            self.chaptersNames = chaptersNames
                        
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
                await send(.time(.forceTimeUpdateOn(-5)))
            }
        case .goForward:
            return .run { send in
                await send(.time(.forceTimeUpdateOn(10)))
            }
        case .previousChapter:
            
            return .concatenate(
                handlePreviousChapterAction(state: &state),
                .run(operation: { send in
                    await send(.time(.forceTimeRefresh))
                }))
        case .nextChapter:
            
            return .concatenate(
                handleNextChapterAction(state: &state),
                .run(operation: { send in
                    await send(.time(.forceTimeRefresh))
                }))
        }
    }
    
    // MARK: - Chapters
    private func handlePreviousChapterAction(state: inout State) -> Effect<Action> {
        
        guard state.chapterNumber > 1 else { return .none }
        
        state.player.pause()
        state.chapterNumber -= 1
        onChapterIndexUpdate(state: &state)
        
        return .none
    }
    
    private func handleNextChapterAction(state: inout State) -> Effect<Action> {
        
        guard state.chapterNumber < state.totalChapters else { return .none }
        
        state.player.pause()
        state.chapterNumber += 1
        onChapterIndexUpdate(state: &state)
        
        return .none
    }
    
    private func onChapterIndexUpdate(state: inout State) {
        
        if let fileName = state.chaptersNames[safe: state.chapterNumber - 1],
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            
            state.player.setFile(with: url)
        }
    }
}

// MARK: - Instantiate
extension PlayerReducer {
    
    static var storeInstance: StoreOf<PlayerReducer> {
        
        var player: (any BookPlayer)?
        
        let chapters = AudioFilesNamesProvider().get
        
        if let fileName = chapters.first,
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            player = AVBookPlayer(with: url)
        } else {
            fatalError("No mp3 files found.")
        }
        
        let store = Store(initialState: PlayerReducer.State(player: player!,
                                                            chaptersNames: chapters),
                          reducer: { PlayerReducer() })
        
        player?.isPlayingUpdated = { [weak store] in
            store?.send(.isPlayingUpdated)
        }
        
        player?.onFinish = { [weak store] in
            store?.send(.audioControlButtonTapped(.nextChapter))
        }
        
        return store
    }
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<PlayerReducer> { storeInstance }
}

// MARK: - Utils
extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
