//
//  BookPlayer.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation
import AVFoundation
import Combine

protocol BookPlayer: Equatable, AnyObject {
    
    var isPlaying: Bool { get }
    
    var currentTime: TimeInterval { get set }
    var duration: TimeInterval { get }
    var speed: Double { get set }
    
    var isPlayingUpdated: (() -> ())? { get set }
    
    var onFinish: (() -> ())? { get set }
        
    func play()
    func pause()
    
    func setFile(with url: URL)
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
        
    var isPlayingUpdated: (() -> ())?
    var onFinish: (() -> ())?

    private var player: AVAudioPlayer?
    
    init(with url: URL) {
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.enableRate = true
        
        super.init()
        
        player?.delegate = self
        fixSpeakers()
    }
    
    func play() {
        
        player?.play()
        isPlayingUpdated?()
    }
    
    func pause() {
        
        player?.pause()
        isPlayingUpdated?()
    }
    
    func setFile(with url: URL) {
        
        let tmpSpeed = speed
        
        player = nil
        player = try? AVAudioPlayer(contentsOf: url)
        player?.enableRate = true
        player?.delegate = self
        
        fixSpeakers()
        
        speed = tmpSpeed
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
        isPlayingUpdated?()
        onFinish?()
    }
}

// MARK: - Preview
extension AVBookPlayer {
    
    /// Only for SwiftUI #Preview
    static var previewInstance: any BookPlayer {
        
        if let fileName = AudioFilesNamesProvider().get.first,
           let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            return AVBookPlayer(with: url)
        }
            
        fatalError("No mp3 files found.")
    }
}
