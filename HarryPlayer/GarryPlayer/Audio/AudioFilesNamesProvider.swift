//
//  AudioFilesNamesProvider.swift
//  GarryPlayer
//
//  Created by Oleksii on 27.07.2024.
//

import Foundation

struct AudioFilesNamesProvider {
    
    var get: [String] {
        
        guard let resourcePath = Bundle.main.resourcePath else {
            return []
        }
        
        do {
            
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
            
            return files.filter({ $0.hasSuffix(".mp3") })
                .compactMap({ $0.replacingOccurrences(of: ".mp3", with: "") })
                .sorted()
        } catch {
            print("Error while enumerating files in \(resourcePath): \(error.localizedDescription)")
            return []
        }
    }
}
