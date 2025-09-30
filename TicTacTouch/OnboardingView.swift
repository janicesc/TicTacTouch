import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var playerName: String = ""
    @State private var selectedAvatar: String = "🎯"
    @State private var selectedPlayStyle: PlayStyle = .strategic
    @State private var playerMotto: String = ""
    @State private var selectedTheme: Theme = .dark
    @State private var soundEnabled: Bool = true
    @State private var currentPage: Int = 0
    @State private var speechSynth = AVSpeechSynthesizer()
    
    private let avatars = ["🎯", "🚀", "⭐", "🎪", "🎨", "🎭", "🎲", "🎸", "🏆", "🔥"]
    private let mottoSuggestions = [
        "Victory or nothing!",
        "May the odds be ever in your favor",
        "Game on!",
        "Bring it on!",
        "Let's do this!",
        "Ready to win!",
        "Challenge accepted!",
        "Time to dominate!"
    ]
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[selectedTheme] ?? ThemeColors.themes[.dark]!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage ? currentTheme.accent : currentTheme.border)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Content based on current page
            TabView(selection: $currentPage) {
                // Page 1: Welcome & Name
                welcomePage
                    .tag(0)
                
                // Page 2: Avatar & Play Style
                avatarPage
                    .tag(1)
                
                // Page 3: Motto & Theme
                customizationPage
                    .tag(2)
                
                // Page 4: Preferences
                preferencesPage
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                        triggerHaptic(.light)
                    }
                    .foregroundColor(currentTheme.accent)
                    .font(.system(size: 16, weight: .medium))
                }
                
                Spacer()
                
                Button(currentPage == 3 ? "Start Playing!" : "Next") {
                    if currentPage == 3 {
                        completeOnboarding()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                        triggerHaptic(.light)
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(currentTheme.accent)
                .cornerRadius(20)
                .disabled(currentPage == 0 && playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(currentTheme.background)
        .onAppear {
            // Set initial values from profile if they exist
            playerName = gameManager.playerProfile.name
            selectedAvatar = gameManager.playerProfile.avatar
            selectedPlayStyle = gameManager.playerProfile.playStyle
            playerMotto = gameManager.playerProfile.motto
            selectedTheme = gameManager.playerProfile.favoriteTheme
            soundEnabled = gameManager.soundEnabled
        }
    }
    
    // MARK: - Pages
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("🎮")
                    .font(.system(size: 60))
                
                Text("Welcome to")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(currentTheme.text)
                
                Text("TIC TAC TOUCH")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(currentTheme.accent)
            }
            
            VStack(spacing: 20) {
                Text("Let's get to know you!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentTheme.text)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("What should we call you?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(currentTheme.text)
                    
                    TextField("Enter your name", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var avatarPage: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("Choose Your Avatar")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(currentTheme.text)
                
                Text("Pick an emoji that represents you!")
                    .font(.system(size: 16))
                    .foregroundColor(currentTheme.text.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Avatar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(avatars, id: \.self) { avatar in
                    Button(action: {
                        selectedAvatar = avatar
                        triggerHaptic(.light)
                        playSound(.emojiSelect)
                    }) {
                        Text(avatar)
                            .font(.system(size: 40))
                            .frame(width: 60, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedAvatar == avatar ? currentTheme.accent : currentTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(currentTheme.border, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Play Style selection
            VStack(spacing: 16) {
                Text("What's your play style?")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentTheme.text)
                
                VStack(spacing: 12) {
                    ForEach(PlayStyle.allCases, id: \.self) { style in
                        Button(action: {
                            selectedPlayStyle = style
                            triggerHaptic(.light)
                            playSound(.playStyleSelect)
                        }) {
                            HStack {
                                Text(style.emoji)
                                    .font(.system(size: 24))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(style.displayName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(currentTheme.text)
                                    
                                    Text(style.description)
                                        .font(.system(size: 14))
                                        .foregroundColor(currentTheme.text.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                if selectedPlayStyle == style {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(currentTheme.accent)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedPlayStyle == style ? currentTheme.accent.opacity(0.1) : currentTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedPlayStyle == style ? currentTheme.accent : currentTheme.border, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    private var customizationPage: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("Personal Touch")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(currentTheme.text)
                
                Text("Add some personality to your game!")
                    .font(.system(size: 16))
                    .foregroundColor(currentTheme.text.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Motto selection
            VStack(spacing: 16) {
                Text("Choose your battle cry:")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentTheme.text)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(mottoSuggestions, id: \.self) { motto in
                        Button(action: {
                            playerMotto = motto
                            triggerHaptic(.light)
                            playBattleCrySound(for: motto)
                        }) {
                            Text(motto)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(currentTheme.text)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(playerMotto == motto ? currentTheme.accent : currentTheme.cardBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(currentTheme.border, lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Custom motto input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or write your own:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(currentTheme.text)
                    
                    TextField("Your custom motto", text: $playerMotto)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 14))
                        .onChange(of: playerMotto) { _, newValue in
                            if !newValue.isEmpty {
                                playBattleCrySound(for: newValue)
                            }
                        }
                }
                .padding(.horizontal, 20)
            }
            
            // Theme preview
            VStack(spacing: 16) {
                Text("Preview themes:")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentTheme.text)
                
                HStack(spacing: 12) {
                    ForEach(Theme.allCases.prefix(3), id: \.self) { theme in
                        Button(action: {
                            selectedTheme = theme
                            triggerHaptic(.light)

                            // Play theme sound effect
                            switch theme {
                            case .light:
                                playSound(.themeLight)
                            case .dark:
                                playSound(.themeDark)
                            case .neon:
                                playSound(.themeNeon)
                            default:
                                break   // retro and watercolor fall here
                            }
                        }) {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(ThemeColors.themes[theme]?.accent ?? Color.blue)
                                    .frame(width: 40, height: 40)

                                Text(theme.rawValue.capitalized)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(currentTheme.text)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTheme == theme ? currentTheme.accent.opacity(0.1) : currentTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedTheme == theme ? currentTheme.accent : currentTheme.border, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    private var preferencesPage: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("Final Setup")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(currentTheme.text)
                
                Text("Almost ready to play!")
                    .font(.system(size: 16))
                    .foregroundColor(currentTheme.text.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Sound preference
            VStack(spacing: 20) {
                HStack {
                    Text("🔊")
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sound Effects")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(currentTheme.text)
                        
                        Text("Enable audio feedback and music")
                            .font(.system(size: 14))
                            .foregroundColor(currentTheme.text.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $soundEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: currentTheme.accent))
                        .onChange(of: soundEnabled) { oldValue, newValue in
                            if !oldValue && newValue {
                                playSound(.soundToggle)
                            }
                        }
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
            }
            
            // Profile summary
            VStack(spacing: 16) {
                Text("Your Profile")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentTheme.text)
                
                VStack(spacing: 12) {
                    HStack {
                        Text(selectedAvatar)
                            .font(.system(size: 32))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(playerName.isEmpty ? "Player" : playerName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(currentTheme.text)
                            
                            Text("\(selectedPlayStyle.emoji) \(selectedPlayStyle.displayName)")
                                .font(.system(size: 14))
                                .foregroundColor(currentTheme.text.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    
                    if !playerMotto.isEmpty {
                        Text("\"\(playerMotto)\"")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(currentTheme.accent)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
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
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        // Check if this is the first time completing onboarding
        let isFirstTime = !gameManager.playerProfile.hasCompletedOnboarding
        
        // Save profile data
        gameManager.playerProfile.name = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        gameManager.playerProfile.avatar = selectedAvatar
        gameManager.playerProfile.playStyle = selectedPlayStyle
        gameManager.playerProfile.motto = playerMotto
        gameManager.playerProfile.favoriteTheme = selectedTheme
        gameManager.playerProfile.hasCompletedOnboarding = true
        
        // If this is the first time, ensure fresh stats
        if isFirstTime {
            gameManager.gameStats = GameStats()
        }
        
        // Update game settings
        gameManager.theme = selectedTheme
        gameManager.soundEnabled = soundEnabled
        
        // Save data
        gameManager.saveGameData()
        
        // Trigger haptic and sound
        triggerHaptic(.medium)
        playSound(.button)
        
        // Navigate to menu
        withAnimation(.easeInOut(duration: 0.5)) {
            gameManager.gameState = .menu
        }
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    private func playSound(_ type: SoundType) {
        gameManager.playSound(type)
    }
    
    private func playBattleCrySound(for motto: String) {
        // stop any narration already in progress
        if speechSynth.isSpeaking {
            speechSynth.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: motto)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.1
        
        speechSynth.speak(utterance)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(GameManager())
}
