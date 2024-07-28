//
//  MockBookPlayer.swift
//  GarryPlayerTests
//
//  Created by Oleksii on 28.07.2024.
//

@testable import GarryPlayer
import Foundation

class MockBookPlayer: BookPlayer {
    
    var speed: Double = 1.0
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 15.0
    var duration: TimeInterval = 120.0
    
    var onFinish: (() -> Void)?
    var isPlayingUpdated: (() -> ())?
    
    func play() {
        isPlaying = true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func setFile(with url: URL) { }
    
    static func == (lhs: MockBookPlayer, rhs: MockBookPlayer) -> Bool {
        return lhs === rhs
    }
}
