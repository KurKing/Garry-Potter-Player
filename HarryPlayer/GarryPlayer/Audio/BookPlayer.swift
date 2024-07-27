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
    
    func play()
    func pause()
    
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
            player?.currentTime = newValue
        }
    }
    
    private var player: AVAudioPlayer?
    
    override init() {
        
        if let fileName = AudioFilesNamesProvider().get.first,
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
        }
        
        player?.enableRate = true
        
        let session = AVAudioSession.sharedInstance()
        
        if let _ = try? session.setCategory(.playback) { } else {
            if let _ = try? session.overrideOutputAudioPort(.speaker) { } else {
                try? session.setActive(true)
            }
        }
        
        super.init()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func set(speed: Double) {
        player?.rate = Float(speed)
    }
    
    
}

// MARK: - AVAudioPlayerDelegate
extension AVBookPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, 
                                     successfully flag: Bool) {
        player.stop()
    }
}
