import Foundation
import SwiftUI

// MARK: - Game Models

enum Player: String, CaseIterable, Codable {
    case X = "X"
    case O = "O"
    case none = ""
}

enum GameState {
    case menu
    case playing
    case finished
}

enum SoundType {
    // Piano-style tones (GameManager generated)
    case tap, win, lose, tie, button, winLine, failSequence
    case emojiSelect, playStyleSelect, soundToggle
    
    // Theme background MP3s (SoundManager handled)
    case themeLight, themeDark, themeNeon
    
    // Battle cry narrations (GameManager voice synthesis)
    case battleCryVictory, battleCryFavor, battleCryGame
    case battleCryBring, battleCryLets, battleCryReady
    case battleCryChallenge, battleCryDominate, battleCryCustom
}

enum Difficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case optimus = "optimus"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .optimus: return "Optimus"
        }
    }
}

enum Theme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case neon = "neon"
    case retro = "retro"
    case watercolor = "watercolor"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .neon: return "Neon"
        case .retro: return "Retro"
        case .watercolor: return "Water"
        }
    }
    
    var unlockRequirement: Int {
        switch self {
        case .light, .dark, .neon: return 0
        case .retro: return 5
        case .watercolor: return 10
        }
    }
}

// MARK: - Win Line

struct Line {
    let a: Int
    let b: Int
    let c: Int
    
    var indices: [Int] { [a, b, c] }
}

let winningLines: [Line] = [
    // Horizontal
    Line(a: 0, b: 1, c: 2), Line(a: 3, b: 4, c: 5), Line(a: 6, b: 7, c: 8),
    // Vertical
    Line(a: 0, b: 3, c: 6), Line(a: 1, b: 4, c: 7), Line(a: 2, b: 5, c: 8),
    // Diagonal
    Line(a: 0, b: 4, c: 8), Line(a: 2, b: 4, c: 6)
]

// Keep the old struct for backward compatibility during transition
struct WinLine {
    let start: (row: Int, col: Int)
    let end: (row: Int, col: Int)
    let direction: WinDirection
}

enum WinDirection: Codable {
    case horizontal
    case vertical
    case diagonal
}

// MARK: - Game Statistics

struct GameStats: Codable {
    var winStreak: Int = 0
    var bestStreak: Int = 0
    var fastestWin: Int = 0
    var totalWins: Int = 0
    var totalLosses: Int = 0
    var totalTies: Int = 0
    var gamesPlayed: Int = 0
    var totalPlayTime: Int = 0 // Total seconds played
    var averageGameTime: Int = 0
    var perfectGames: Int = 0 // Games won in minimum moves (5 moves)
    var difficultyStats: [String: DifficultyStats] = [:]
    
    var winPercentage: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(totalWins) / Double(gamesPlayed) * 100.0
    }
    
    var averageGameTimeFormatted: String {
        guard gamesPlayed > 0 else { return "0s" }
        let avg = totalPlayTime / gamesPlayed
        if avg < 60 {
            return "\(avg)s"
        } else {
            let minutes = avg / 60
            let seconds = avg % 60
            return "\(minutes)m \(seconds)s"
        }
    }
}

// MARK: - Player Profile

struct PlayerProfile: Codable {
    var name: String = ""
    var avatar: String = "🎯"
    var playStyle: PlayStyle = .strategic
    var motto: String = ""
    var favoriteTheme: Theme = .dark
    var hasCompletedOnboarding: Bool = false
    
    var displayName: String {
        return name.isEmpty ? "Player" : name
    }
    
    // Custom coding keys to exclude computed properties
    private enum CodingKeys: String, CodingKey {
        case name, avatar, playStyle, motto, favoriteTheme, hasCompletedOnboarding
    }
}

enum PlayStyle: String, CaseIterable, Codable {
    case aggressive = "aggressive"
    case strategic = "strategic"
    case lucky = "lucky"
    case chill = "chill"
    
    var displayName: String {
        switch self {
        case .aggressive: return "Aggressive"
        case .strategic: return "Strategic"
        case .lucky: return "Lucky"
        case .chill: return "Chill"
        }
    }
    
    var emoji: String {
        switch self {
        case .aggressive: return "⚡"
        case .strategic: return "🧠"
        case .lucky: return "🍀"
        case .chill: return "😎"
        }
    }
    
    var description: String {
        switch self {
        case .aggressive: return "Go for the win!"
        case .strategic: return "Think before you move"
        case .lucky: return "Fortune favors the bold"
        case .chill: return "Just have fun"
        }
    }
}

struct DifficultyStats: Codable {
    var gamesPlayed: Int = 0
    var wins: Int = 0
    var losses: Int = 0
    var ties: Int = 0
    var fastestWin: Int = 0
    
    var winPercentage: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(wins) / Double(gamesPlayed) * 100.0
    }
}

// MARK: - Theme Colors

struct ThemeColors {
    let background: Color
    let cardBg: Color
    let text: Color
    let accent: Color
    let xColor: Color
    let oColor: Color
    let border: Color
    let shadow: Color
    
    static let themes: [Theme: ThemeColors] = [
        .light: ThemeColors(
            background: Color(hex: "f8fafc"),
            cardBg: Color(hex: "ffffff"),
            text: Color(hex: "1e293b"),
            accent: Color(hex: "3b82f6"),
            xColor: Color(hex: "ef4444"),
            oColor: Color(hex: "8b5cf6"),
            border: Color(hex: "e2e8f0"),
            shadow: Color(hex: "000000").opacity(0.1)
        ),
        .dark: ThemeColors(
            background: Color(hex: "0f172a"),
            cardBg: Color(hex: "1e293b"),
            text: Color(hex: "f1f5f9"),
            accent: Color(hex: "06b6d4"),
            xColor: Color(hex: "22c55e"),
            oColor: Color(hex: "ec4899"),
            border: Color(hex: "334155"),
            shadow: Color(hex: "000000").opacity(0.3)
        ),
        .neon: ThemeColors(
            background: Color(hex: "000011"),
            cardBg: Color(hex: "1a1a2e"),
            text: Color(hex: "00ffff"),
            accent: Color(hex: "ff00ff"),
            xColor: Color(hex: "00ff00"),
            oColor: Color(hex: "ff00ff"),
            border: Color(hex: "00ffff"),
            shadow: Color(hex: "00ffff").opacity(0.3)
        ),
        .retro: ThemeColors(
            background: Color(hex: "2d1b69"),
            cardBg: Color(hex: "413496"),
            text: Color(hex: "fbbf24"),
            accent: Color(hex: "f59e0b"),
            xColor: Color(hex: "ef4444"),
            oColor: Color(hex: "3b82f6"),
            border: Color(hex: "7c3aed"),
            shadow: Color(hex: "7c3aed").opacity(0.3)
        ),
        .watercolor: ThemeColors(
            background: Color(hex: "fef3c7"),
            cardBg: Color(hex: "fef9e7"),
            text: Color(hex: "78350f"),
            accent: Color(hex: "059669"),
            xColor: Color(hex: "dc2626"),
            oColor: Color(hex: "2563eb"),
            border: Color(hex: "d97706"),
            shadow: Color(hex: "d97706").opacity(0.2)
        )
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
