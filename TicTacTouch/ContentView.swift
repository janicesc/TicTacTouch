import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            currentTheme.background
                .ignoresSafeArea()
            
            if !gameManager.playerProfile.hasCompletedOnboarding {
                OnboardingView()
            } else {
                switch gameManager.gameState {
                case .menu:
                    MenuView()
                case .playing, .finished:
                    GameView()
                }
            }
        }
        .environmentObject(gameManager)
    }
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
}

// MARK: - Menu View

struct MenuView: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Welcome section
            HStack(spacing: 12) {
                Text(gameManager.playerProfile.avatar)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome back,")
                        .font(.system(size: 14))
                        .foregroundColor(currentTheme.text.opacity(0.7))
                    
                    Text(gameManager.playerProfile.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(currentTheme.text)
                }
                
                Spacer()
                
                Text(gameManager.playerProfile.playStyle.emoji)
                    .font(.system(size: 24))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentTheme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currentTheme.border, lineWidth: 1)
                    )
            )
            
            // Title
            Button(action: {
                gameManager.triggerHaptic(.medium)
                gameManager.playSound(.button)
            }) {
                Text("TIC TAC TOUCH")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(currentTheme.accent)
            }
            
            Text("Ultra-Responsive Edition")
                .font(.system(size: 16))
                .foregroundColor(currentTheme.text)
                .opacity(0.8)
            
            // Player motto
            if !gameManager.playerProfile.motto.isEmpty {
                Text("\"\(gameManager.playerProfile.motto)\"")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(currentTheme.accent)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Stats Card
            MenuStatsCard()
            
            // Play Button
            Button(action: gameManager.startNewGame) {
                HStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 24))
                    Text("PLAY GAME")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(currentTheme.accent)
                .cornerRadius(25)
            }
            
            // Settings
            HStack(spacing: 20) {
                Button(action: {
                    gameManager.toggleSound()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: gameManager.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 16))
                        Text("Sound")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(currentTheme.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentTheme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentTheme.border, lineWidth: 1)
                            )
                    )
                }
                
                Button(action: {
                    gameManager.resetOnboarding()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 16))
                        Text("Profile")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(currentTheme.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentTheme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentTheme.border, lineWidth: 1)
                            )
                    )
                }
            }
            
            // Features
            VStack(spacing: 8) {
                FeatureText("✨ Haptic feedback & sound effects")
                FeatureText("🎨 Multiple themes (unlock with wins!)")
                FeatureText("🤖 Smart AI with 4 difficulty levels")
                FeatureText("📊 Track your progress & streaks")
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    @ViewBuilder
    private func FeatureText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(currentTheme.text)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Game View

struct GameView: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Stats Header
                GameStatsHeader()
                
                // Turn Display / Winner Display
                TurnDisplayView()
                
                // Game Board
                GameBoardView()
            
            // Controls
            VStack(spacing: 20) {
                // New Game Button
                Button(action: gameManager.startNewGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                        Text("New Game")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(currentTheme.accent)
                    .cornerRadius(20)
                }
                
                // Difficulty Selection
                VStack(spacing: 10) {
                    Text("Difficulty")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(currentTheme.text)
                    
                    HStack(spacing: 8) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Button(action: {
                                gameManager.difficulty = difficulty
                                gameManager.triggerHaptic(.light)
                                gameManager.playSound(.button)
                            }) {
                                Text(difficulty.displayName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(gameManager.difficulty == difficulty ? .white : currentTheme.text)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        gameManager.difficulty == difficulty ? currentTheme.accent : currentTheme.cardBg
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(currentTheme.border, lineWidth: 1)
                                    )
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                
                // Theme Selection
                VStack(spacing: 10) {
                    Text("Theme")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(currentTheme.text)
                    
                    HStack(spacing: 8) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            ThemeButton(theme: theme)
                        }
                    }
                }
                
                // Sound Toggle
                Button(action: gameManager.toggleSound) {
                    HStack(spacing: 8) {
                        Image(systemName: gameManager.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 20))
                        Text("Sound \(gameManager.soundEnabled ? "On" : "Off")")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(currentTheme.accent)
                    .cornerRadius(16)
                }
            }
            
                Spacer()
            }
            .padding(20)
            
            // Settings button in top-right corner
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        gameManager.gameState = .menu
                        gameManager.triggerHaptic(.light)
                        gameManager.playSound(.button)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(currentTheme.text)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(currentTheme.cardBg)
                                    .overlay(
                                        Circle()
                                            .stroke(currentTheme.border, lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Turn Display View

struct TurnDisplayView: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if gameManager.winner != .none || gameManager.isTie {
                // Show winner message
                Image(systemName: "trophy.fill")
                    .foregroundColor(gameManager.winner == .X ? currentTheme.xColor : currentTheme.accent)
                Text(winnerText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(currentTheme.text)
            } else {
                // Show current turn
                Text("Current Turn:")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(currentTheme.text)
                
                if gameManager.currentPlayer == .X {
                    Text("X")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(currentTheme.xColor)
                        .shadow(color: currentTheme.xColor, radius: gameManager.theme == .neon ? 10 : 0)
                } else {
                    Text("O")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(currentTheme.oColor)
                        .shadow(color: currentTheme.oColor, radius: gameManager.theme == .neon ? 10 : 0)
                    
                    Text("Thinking...")
                        .font(.system(size: 18, weight: .bold))
                        .italic()
                        .foregroundColor(currentTheme.text)
                        .opacity(0.8)
                }
            }
        }
        .padding(16)
        .background(currentTheme.cardBg)
        .cornerRadius(12)
    }
    
    private var winnerText: String {
        if gameManager.isTie {
            return "Tie game!"
        } else if gameManager.winner == .X {
            return "You win!"
        } else {
            return "AI wins!"
        }
    }
}

// MARK: - Game Stats Header

struct GameStatsHeader: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        HStack {
            StatItem(label: "Win Streak", value: "\(gameManager.gameStats.winStreak)")
            StatItem(label: "Best Streak", value: "\(gameManager.gameStats.bestStreak)")
            StatItem(label: "Fastest Win", value: gameManager.gameStats.fastestWin > 0 ? "\(gameManager.gameStats.fastestWin)s" : "-")
            StatItem(label: "Games", value: "\(gameManager.gameStats.gamesPlayed)")
        }
        .padding(16)
        .background(currentTheme.cardBg)
        .cornerRadius(12)
    }
}

// MARK: - Menu Stats Card

struct MenuStatsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Your Stats")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(currentTheme.text)
            
            HStack {
                LeftStatsColumn()
                Spacer()
                RightStatsColumn()
            }
            
            if gameManager.gameStats.gamesPlayed > 0 {
                Text("Avg Game Time: \(gameManager.gameStats.averageGameTimeFormatted)")
                    .font(.system(size: 12))
                    .foregroundColor(currentTheme.text)
                    .opacity(0.8)
            }
        }
        .padding(20)
        .background(currentTheme.cardBg)
        .cornerRadius(12)
        .frame(maxWidth: 300)
    }
}

struct LeftStatsColumn: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Wins: \(gameManager.gameStats.totalWins)")
            Text("Losses: \(gameManager.gameStats.totalLosses)")
            Text("Ties: \(gameManager.gameStats.totalTies)")
        }
        .font(.system(size: 14))
        .foregroundColor(currentTheme.accent)
    }
}

struct RightStatsColumn: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    private var winRateText: String {
        String(format: "%.1f", gameManager.gameStats.winPercentage)
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Win Rate: \(winRateText)%")
            Text("Best Streak: \(gameManager.gameStats.bestStreak)")
            Text("Perfect Games: \(gameManager.gameStats.perfectGames)")
        }
        .font(.system(size: 14))
        .foregroundColor(currentTheme.accent)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let label: String
    let value: String
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(currentTheme.text)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(currentTheme.accent)
        }
    }
}

struct ThemeButton: View {
    let theme: Theme
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    private var isLocked: Bool {
        theme.unlockRequirement > gameManager.gameStats.totalWins
    }
    
    var body: some View {
        Button(action: {
            if !isLocked {
                gameManager.toggleTheme(theme)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(gameManager.theme == theme ? currentTheme.accent : currentTheme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(currentTheme.border, lineWidth: 1)
                    )
                    .frame(width: 50, height: 40)
                    .opacity(isLocked ? 0.5 : 1.0)
                
                VStack {
                    themeIcon
                    if isLocked {
                        Text("🔒")
                            .font(.system(size: 12))
                            .offset(x: 15, y: -15)
                    }
                }
            }
        }
        .disabled(isLocked)
    }
    
    @ViewBuilder
    private var themeIcon: some View {
        switch theme {
        case .light:
            Image(systemName: "sun.max.fill")
                .font(.system(size: 20))
                .foregroundColor(gameManager.theme == theme ? .white : currentTheme.text)
        case .dark:
            Image(systemName: "moon.fill")
                .font(.system(size: 20))
                .foregroundColor(gameManager.theme == theme ? .white : currentTheme.text)
        case .neon:
            Image(systemName: "bolt.fill")
                .font(.system(size: 20))
                .foregroundColor(gameManager.theme == theme ? .white : currentTheme.text)
        case .retro:
            Text("Retro")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(gameManager.theme == theme ? .white : currentTheme.text)
        case .watercolor:
            Text("Water")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(gameManager.theme == theme ? .white : currentTheme.text)
        }
    }
}

// MARK: - Previews

#Preview("Menu Screen") {
    ContentView()
        .preferredColorScheme(.dark)
}
