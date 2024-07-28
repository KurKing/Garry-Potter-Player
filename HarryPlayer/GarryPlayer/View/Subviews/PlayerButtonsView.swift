//
//  PlayerButtonsView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlayingButtonsView: View {

    let store: StoreOf<PlayerReducer>
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            ForEach(AudioControlAction.availableFeatures, id: \.self) { action in
                
                let size: CGFloat = action == .play ? 40.0 : 35.0
                let isAvailable = isAvailable(action: action)
                
                Button(action: {
                    store.send(.audioControlButtonTapped(action))
                }) {
                    Image(systemName: action.imageName(isPlaying: store.isPlaying))
                        .resizable()
                        .scaledToFit()
                        .font(.system(size: 30))
                        .foregroundStyle(.black)
                        .frame(width: size, height: size, alignment: .center)
                }
                .disabled(!isAvailable)
                .opacity(isAvailable ? 1.0 : 0.4)
                
                Spacer()
            }
        }
    }
    
    private func isAvailable(action: AudioControlAction) -> Bool {
        
        if action == .previousChapter, !store.state.isPreviousChapterAvailable {
            return false
        }
        
        if action == .nextChapter, !store.state.isNextChapterAvailable {
            return false
        }
        
        if action == .goBackward, !store.state.timeState.isTimeBackButtonAvailable {
            return false
        }
        
        if action == .goForward, !store.state.timeState.isTimeForwardButtonAvailable {
            return false
        }
        
        return true
    }
}

fileprivate extension AudioControlAction {
    
    func imageName(isPlaying: Bool) -> String {
       
       switch self {
       case .previousChapter:
           "backward.fill"
       case .goBackward:
           "gobackward.5"
       case .play:
           if isPlaying {
               "pause.fill"
           } else {
               "play.fill"
           }
       case .goForward:
           "goforward.10"
       case .nextChapter:
           "forward.fill"
       }
   }
}

#Preview {
    PlayingButtonsView(store: PlayerReducer.previewStore)
}
