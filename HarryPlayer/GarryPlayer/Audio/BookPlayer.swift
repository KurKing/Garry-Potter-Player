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
    var speed: Double { get set }
    
    var onFinish: (() -> ())? { get set }
    
    func play()
    func pause()
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
    
    var speed: Double {
        get {
            Double(player?.rate ?? 1.0)
        }
        set {
            player?.rate = Float(newValue)
        }
    }
    
    var onFinish: (() -> ())?
    
    private var player: AVAudioPlayer?
    
    init(with url: URL) {
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.enableRate = true
        
        super.init()
        
        fixSpeakers()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    private func fixSpeakers() {
        
        let session = AVAudioSession.sharedInstance()

        if let _ = try? session.setCategory(.playback) { } else {
            if let _ = try? session.overrideOutputAudioPort(.speaker) { } else {
                try? session.setActive(true)
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AVBookPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, 
                                     successfully flag: Bool) {
        player.stop()
        onFinish?()
    }
}
