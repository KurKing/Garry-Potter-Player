//
//  BookPlayer.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation
import AVFoundation

protocol BookPlayer: Equatable {
    
    var isPlaying: Bool { get }
    
    var currentTime: TimeInterval { get set }
    var duration: TimeInterval { get }
    
    /// Play or pause audio
    func play()
    
    func set(speed: Double)
}

class AVBookPlayer: NSObject, BookPlayer {
    
    var isPlaying: Bool { player?.isPlaying ?? false }
    var duration: TimeInterval { player?.duration ?? 0.0 }
    var currentTime: TimeInterval {
        get {
            player?.currentTime ?? 0.0
        }
        set {
            Task(priority: .high) {
                await set(time: newValue)
            }
        }
    }
    
    private var player: AVAudioPlayer?
    
    override init() {
        
        if let fileName = AudioFilesNamesProvider().get.first,
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
        }
        
        player?.enableRate = true
        
        super.init()
    }
    
    func play() {
        
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
    }
    
    func set(speed: Double) {
        
        Task(priority: .high) {
            player?.rate = Float(speed)
        }
    }
    
    private func set(time: TimeInterval) async {
        player?.currentTime = time
    }
}

// MARK: - AVAudioPlayerDelegate
extension AVBookPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, 
                                     successfully flag: Bool) {
        player.stop()
    }
}
