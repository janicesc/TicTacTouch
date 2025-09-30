import Foundation
import SwiftUI
import AVFoundation

class GameManager: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var board: [Player] = Array(repeating: .none, count: 9)
    @Published var currentPlayer: Player = .X
    @Published var winner: Player = .none
    @Published var isTie: Bool = false
    @Published var difficulty: Difficulty = .medium
    @Published var theme: Theme = .dark
    @Published var soundEnabled: Bool = true
    @Published var gameStats = GameStats()
    @Published var gameStartTime: Date = Date()
    @Published var winLine: Line?
    @Published var showSettings: Bool = false
    @Published var playerProfile = PlayerProfile()
    
    // Animations
    @Published var cellAnimations: [Double] = Array(repeating: 1.0, count: 9)
    @Published var winLineAnimation: Double = 0.0
    @Published var confettiAnimation: Double = 0.0
    
    // Sound sequence
    private var tapSequence: [Float] = [261.63, 329.63, 261.63, 329.63] // C-E-C-E
    private var tapIndex: Int = 0
    
    // Narration
    private var speechSynth = AVSpeechSynthesizer()
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadGameData()
    }
    
    // MARK: - Persistence
    
    private func loadGameData() {
        if let savedStats = userDefaults.data(forKey: "gameStats"),
           let decodedStats = try? JSONDecoder().decode(GameStats.self, from: savedStats) {
            gameStats = decodedStats
        }
        
        if let savedProfile = userDefaults.data(forKey: "playerProfile"),
           let decodedProfile = try? JSONDecoder().decode(PlayerProfile.self, from: savedProfile) {
            playerProfile = decodedProfile
        }
        
        if let savedTheme = userDefaults.string(forKey: "theme"),
           let themeEnum = Theme(rawValue: savedTheme) {
            theme = themeEnum
        }
        
        if let savedDifficulty = userDefaults.string(forKey: "difficulty"),
           let difficultyEnum = Difficulty(rawValue: savedDifficulty) {
            difficulty = difficultyEnum
        }
        
        soundEnabled = userDefaults.object(forKey: "soundEnabled") as? Bool ?? true
    }
    
    func saveGameData() {
        if let encodedStats = try? JSONEncoder().encode(gameStats) {
            userDefaults.set(encodedStats, forKey: "gameStats")
        }
        
        if let encodedProfile = try? JSONEncoder().encode(playerProfile) {
            userDefaults.set(encodedProfile, forKey: "playerProfile")
        }
        
        userDefaults.set(theme.rawValue, forKey: "theme")
        userDefaults.set(difficulty.rawValue, forKey: "difficulty")
        userDefaults.set(soundEnabled, forKey: "soundEnabled")
    }
    
    // MARK: - Sounds
    
    func playSound(_ soundType: SoundType) {
        guard soundEnabled else { return }
        
        switch soundType {
        case .tap:
            let freq = tapSequence[tapIndex % tapSequence.count]
            tapIndex += 1
            generateAndPlayTone(frequencies: [freq], duration: 0.15)
            
        case .win:
            generateAndPlayTone(frequencies: [523.25], duration: 1.2) // High C note for win
        case .lose:
            generateAndPlayTone(frequencies: [200.0, 180.0, 160.0], duration: 1.0)
        case .tie:
            generateAndPlayTone(frequencies: [300.0, 280.0], duration: 0.6)
        case .button:
            generateAndPlayTone(frequencies: [261.63], duration: 0.1)
        case .winLine:
            generateAndPlayTone(frequencies: [523.25], duration: 0.8)
        case .failSequence:
            generateAndPlayTone(frequencies: [220.0, 200.0, 180.0, 160.0], duration: 1.5)
        case .emojiSelect:
            generateAndPlayTone(frequencies: [261.63, 329.63, 392.00], duration: 0.4)
        case .playStyleSelect:
            generateAndPlayTone(frequencies: [261.63, 329.63, 392.00, 523.25], duration: 0.5)
        case .soundToggle:
            SoundManager.shared.play(.soundToggle)
            
        case .themeLight:
            SoundManager.shared.play(.themeLight)
        case .themeDark:
            SoundManager.shared.play(.themeDark)
        case .themeNeon:
            SoundManager.shared.play(.themeNeon)
            
        default:
            break
        }
    }
    
    func playBattleCryNarration(_ motto: String) {
        guard soundEnabled else { return }
        
        if speechSynth.isSpeaking {
            speechSynth.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: motto)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.1
        speechSynth.speak(utterance)
    }
    
    // MARK: - Tone Generator
    
    private func generateAndPlayTone(frequencies: [Float], duration: Double) {
        let sampleRate: Double = 44100
        let frameCount = Int(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else { return }
        buffer.frameLength = AVAudioFrameCount(frameCount)
        
        let channel = buffer.floatChannelData![0]
        let freqCount = Float(frequencies.count)
        
        for i in 0..<frameCount {
            var sample: Float = 0.0
            let timeValue = Double(i) / sampleRate
            let twoPi = 2.0 * Double.pi
            
            for frequency in frequencies {
                let frequencyDouble = Double(frequency)
                let angle = twoPi * frequencyDouble * timeValue
                let sineValue = sin(angle)
                let amplitude = sineValue * 0.3
                sample += Float(amplitude)
            }
            
            channel[i] = sample / freqCount
        }
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        try? engine.start()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: {
            engine.stop()
        })
        player.play()
    }
    
    // MARK: - Haptics
    
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Game Flow
    
    func startNewGame() {
        board = Array(repeating: .none, count: 9)
        currentPlayer = .X
        winner = .none
        isTie = false
        gameState = .playing
        gameStartTime = Date()
        winLine = nil
        
        // Reset animations
        cellAnimations = Array(repeating: 1.0, count: 9)
        winLineAnimation = 0.0
        confettiAnimation = 0.0
        
        // Reset sound sequence to start with C note
        tapIndex = 0
        
        triggerHaptic(.medium)
        playSound(.button)
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        saveGameData()
        triggerHaptic(.light)
        playSound(.soundToggle)
    }
    
    func toggleTheme(_ theme: Theme) {
        self.theme = theme
        saveGameData()
        triggerHaptic(.light)
        
        switch theme {
        case .light:
            playSound(.themeLight)
        case .dark:
            playSound(.themeDark)
        case .neon:
            playSound(.themeNeon)
        default:
            playSound(.button)
        }
        
        // Temporary: Use button sound if theme sounds fail
        // Remove this after fixing the audio files
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This will play if the theme sound didn't work
        }
    }
    
    func resetOnboarding() {
        playerProfile.hasCompletedOnboarding = false
        saveGameData()
        triggerHaptic(.medium)
        playSound(.button)
    }
    
    func handleCellPress(at index: Int) {
        // Check if game is still active and cell is empty
        guard gameState == .playing,
              board[index] == .none,
              winner == .none,
              !isTie else { return }
        
        // Player X makes move
        board[index] = .X
        triggerHaptic(.light)
        playSound(.tap)
        
        // Check for win or tie
        checkGameState()
        
        // If game continues, AI makes move
        if gameState == .playing {
            // Set current player to O (AI) to show "Thinking..." status
            currentPlayer = .O
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeAIMove()
            }
        }
    }
    
    private func makeAIMove() {
        guard gameState == .playing else { return }
        
        let bestMove = getBestMove()
        board[bestMove] = .O
        triggerHaptic(.light)
        playSound(.tap)
        
        // Set current player back to X (human) for next turn
        currentPlayer = .X
        
        checkGameState()
    }
    
    private func getBestMove() -> Int {
        // Simple AI logic - can be enhanced based on difficulty
        let emptyCells = board.enumerated().compactMap { index, player in
            player == .none ? index : nil
        }
        
        // Try to win first
        for index in emptyCells {
            var testBoard = board
            testBoard[index] = .O
            if checkWinner(board: testBoard) == .O {
                return index
            }
        }
        
        // Try to block player
        for index in emptyCells {
            var testBoard = board
            testBoard[index] = .X
            if checkWinner(board: testBoard) == .X {
                return index
            }
        }
        
        // Take center if available
        if board[4] == .none {
            return 4
        }
        
        // Take corners
        let corners = [0, 2, 6, 8]
        for corner in corners {
            if board[corner] == .none {
                return corner
            }
        }
        
        // Take any available cell
        return emptyCells.randomElement() ?? 0
    }
    
    private func checkGameState() {
        winner = checkWinner(board: board)
        
        if winner != .none {
            gameState = .finished
            handleGameEnd()
        } else if board.allSatisfy({ $0 != .none }) {
            isTie = true
            gameState = .finished
            handleGameEnd()
        }
    }
    
    private func checkWinner(board: [Player]) -> Player {
        let winningLines = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6] // Diagonals
        ]
        
        for line in winningLines {
            let a = board[line[0]]
            let b = board[line[1]]
            let c = board[line[2]]
            
            if a != .none && a == b && b == c {
                // Set the win line for the UI
                winLine = Line(a: line[0], b: line[1], c: line[2])
                return a
            }
        }
        
        // Clear win line if no winner
        winLine = nil
        return .none
    }
    
    private func handleGameEnd() {
        let gameDuration = Int(Date().timeIntervalSince(gameStartTime))
        
        if winner == .X {
            gameStats.totalWins += 1
            gameStats.winStreak += 1
            gameStats.bestStreak = max(gameStats.bestStreak, gameStats.winStreak)
            
            if gameStats.fastestWin == 0 || gameDuration < gameStats.fastestWin {
                gameStats.fastestWin = gameDuration
            }
            
            playSound(.win)
            triggerHaptic(.heavy)
            
            // Trigger win line animation and confetti
            withAnimation(.easeInOut(duration: 1.0)) {
                winLineAnimation = 1.0
                confettiAnimation = 1.0
            }
        } else if winner == .O {
            gameStats.totalLosses += 1
            gameStats.winStreak = 0
            playSound(.lose)
            triggerHaptic(.medium)
            
            // Trigger win line animation
            withAnimation(.easeInOut(duration: 1.0)) {
                winLineAnimation = 1.0
            }
        } else {
            gameStats.totalTies += 1
            playSound(.tie)
            triggerHaptic(.light)
        }
        
        gameStats.gamesPlayed += 1
        saveGameData()
    }
}
