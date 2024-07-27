//
//  GarryPlayerApp.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct GarryPlayerApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            ContentView(store: PlayerFeature.storeInstance)
        }
    }
}
