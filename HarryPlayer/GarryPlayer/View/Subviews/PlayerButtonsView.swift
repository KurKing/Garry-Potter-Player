//
//  PlayerButtonsView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlayingButtonsView: View {

    let store: StoreOf<PlayerFeature>
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            ForEach(AudioControlAction.availableFeatures, id: \.self) { action in
                
                let size: CGFloat = action == .play ? 40.0 : 35.0
                
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
                
                Spacer()
            }
        }
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
    PlayingButtonsView(store: PlayerFeature.previewStore)
}
