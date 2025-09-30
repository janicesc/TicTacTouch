import Foundation
import AVFoundation
import AudioToolbox

final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    
    func play(_ type: SoundType) {
        switch type {
        // Theme MP3s (loaded from Assets catalog)
        case .themeLight:
            playAsset(named: "themeLight")
        case .themeDark:
            playAsset(named: "themeDark")
        case .themeNeon:
            playAsset(named: "themeNeon")
            
        // Sound toggle MP3
        case .soundToggle:
            playAsset(named: "soundon")
            
        // Piano-style tones (GameManager handles these)
        case .tap, .win, .lose, .tie, .button, .winLine, .failSequence,
             .emojiSelect, .playStyleSelect:
            break
            
        // Battle cries (GameManager handles voice synthesis)
        case .battleCryVictory, .battleCryFavor, .battleCryGame,
             .battleCryBring, .battleCryLets, .battleCryReady,
             .battleCryChallenge, .battleCryDominate, .battleCryCustom:
            break
        }
    }
    
    // MARK: - Private helpers
    
    private func playAsset(named name: String) {
        // Try multiple approaches to find the audio file
        var url: URL?
        
        // Method 1: Try as bundle resource with common extensions
        let extensions = ["mp3", "m4a", "wav", "aiff", "caf"]
        for ext in extensions {
            if let foundURL = Bundle.main.url(forResource: name, withExtension: ext) {
                url = foundURL
                break
            }
        }
        
        // Method 2: Try Assets catalog approach
        if url == nil {
            url = Bundle.main.url(forResource: name, withExtension: nil)
        }
        
        // Method 3: Try with different naming conventions
        if url == nil {
            let variations = [
                "\(name)Theme",
                "\(name)Sound", 
                "\(name)Audio",
                name.lowercased(),
                name.uppercased()
            ]
            
            for variation in variations {
                for ext in extensions {
                    if let foundURL = Bundle.main.url(forResource: variation, withExtension: ext) {
                        url = foundURL
                        break
                    }
                }
                if url != nil { break }
            }
        }
        
        guard let finalURL = url else {
            print("⚠️ Missing sound asset: \(name)")
            print("⚠️ Searched for: \(name).mp3, \(name).m4a, \(name).wav, \(name).aiff")
            print("⚠️ Also tried variations and Assets catalog")
            print("⚠️ Available bundle resources:")
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                do {
                    let contents = try fileManager.contentsOfDirectory(atPath: resourcePath)
                    let audioFiles = contents.filter { $0.lowercased().contains("theme") || $0.lowercased().contains("sound") }
                    for file in audioFiles {
                        print("   📁 \(file)")
                    }
                } catch {
                    print("   Error listing resources: \(error)")
                }
            }
            
            // Fallback: Use system sound
            print("🔧 Using system sound as fallback")
            AudioServicesPlaySystemSound(1104) // System "click" sound
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: finalURL)
            player?.prepareToPlay()
            player?.play()
            print("✅ Playing sound: \(finalURL.lastPathComponent)")
        } catch {
            print("⚠️ Error playing sound asset \(name): \(error.localizedDescription)")
        }
    }
    
    private func playFile(named name: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("⚠️ Missing sound file: \(name).\(ext)")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("⚠️ Error playing sound file \(name).\(ext): \(error.localizedDescription)")
        }
    }
}
