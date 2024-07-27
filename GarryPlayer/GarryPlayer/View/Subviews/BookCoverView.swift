//
//  BookCoverView.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct BookCoverView: View {
    
    let store: StoreOf<PlayerFeature>
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 10) {
            
            Image("book-cover")
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.horizontal, 50)
            
            Text("CHAPTER \(store.chapterNumber) OF \(store.totalChapters)")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Text(store.title)
                .font(.headline)
        }
        .padding(.horizontal)
    }
}

#Preview {
    BookCoverView(store: PlayerFeature.previewStore)
}
