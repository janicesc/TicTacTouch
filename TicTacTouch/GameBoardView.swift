import SwiftUI

struct GameBoardView: View {
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    private let cellSize: CGFloat = {
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - 80) / 3
    }()
    
    var body: some View {
        ZStack {
            // Game Board
            GameBoardGrid()
            
            // Win Line
            if let winLine = gameManager.winLine {
                WinLineView(winLine: winLine, cellSize: cellSize)
            }
            
            // Confetti
            if gameManager.winner == .X {
                ConfettiView()
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.fixed(cellSize), spacing: 4),
            GridItem(.fixed(cellSize), spacing: 4),
            GridItem(.fixed(cellSize), spacing: 4)
        ]
    }
    
    private var boardFrame: (width: CGFloat, height: CGFloat) {
        let width = cellSize * 3 + 8
        let height = cellSize * 3 + 8
        return (width, height)
    }
}

struct GameBoardGrid: View {
    @EnvironmentObject var gameManager: GameManager
    
    private let cellSize: CGFloat = {
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - 80) / 3
    }()
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.fixed(cellSize), spacing: 4),
            GridItem(.fixed(cellSize), spacing: 4),
            GridItem(.fixed(cellSize), spacing: 4)
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 4) {
            ForEach(0..<9, id: \.self) { index in
                GameCellView(index: index, cellSize: cellSize)
            }
        }
        .frame(width: cellSize * 3 + 8, height: cellSize * 3 + 8)
    }
}

struct GameCellView: View {
    let index: Int
    let cellSize: CGFloat
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    private var player: Player {
        gameManager.board[index]
    }
    
    var body: some View {
        Button(action: {
            gameManager.handleCellPress(at: index)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentTheme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currentTheme.border, lineWidth: 2)
                    )
                    .frame(width: cellSize, height: cellSize)
                
                if player != .none {
                    Text(player.rawValue)
                        .font(.system(size: cellSize * 0.6, weight: .bold))
                        .foregroundColor(player == .X ? currentTheme.xColor : currentTheme.oColor)
                        .shadow(
                            color: currentTheme.shadow,
                            radius: gameManager.theme == .neon ? 10 : 0
                        )
                }
            }
        }
        .scaleEffect(gameManager.cellAnimations[index])
        .disabled(player != .none || gameManager.winner != .none || gameManager.currentPlayer != .X)
    }
}

struct WinLineView: View {
    let winLine: Line
    let cellSize: CGFloat
    @EnvironmentObject var gameManager: GameManager
    
    private var currentTheme: ThemeColors {
        ThemeColors.themes[gameManager.theme] ?? ThemeColors.themes[.dark]!
    }
    
    private var winLineColor: Color {
        // Use the color of the winning player
        if gameManager.winner == .X {
            return currentTheme.xColor
        } else if gameManager.winner == .O {
            return currentTheme.oColor
        } else {
            return currentTheme.accent
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 4
            let cell = cellSize
            
            // Calculate points based on cell indices
            let points = winLine.indices.map { idx -> CGPoint in
                let row = idx / 3, col = idx % 3
                return CGPoint(
                    x: CGFloat(col) * (cell + spacing) + cell / 2,
                    y: CGFloat(row) * (cell + spacing) + cell / 2
                )
            }
            
            if let start = points.first, let end = points.last {
                Path { path in
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .trim(from: 0, to: gameManager.winLineAnimation)
                .stroke(
                    winLineColor,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .shadow(
                    color: winLineColor,
                    radius: gameManager.theme == .neon ? 10 : 0
                )
            }
        }
        .frame(width: cellSize * 3 + 8, height: cellSize * 3 + 8)
    }
}

struct ConfettiView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            ConfettiEmojis()
            WinnerText()
            Spacer()
        }
    }
}

struct ConfettiEmojis: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { index in
                ConfettiEmoji(index: index)
            }
        }
    }
}

struct ConfettiEmoji: View {
    let index: Int
    @EnvironmentObject var gameManager: GameManager
    
    private var xOffset: CGFloat {
        CGFloat(index - 1) * 30 * gameManager.confettiAnimation
    }
    
    private var yOffset: CGFloat {
        -80 * gameManager.confettiAnimation
    }
    
    private var rotation: Double {
        360 * gameManager.confettiAnimation + Double(index) * 120
    }
    
    var body: some View {
        Text("🎉")
            .font(.system(size: 40))
            .opacity(gameManager.confettiAnimation)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .animation(.easeInOut(duration: 1.0), value: gameManager.confettiAnimation)
    }
}

struct WinnerText: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        Text("WINNER!")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.yellow)
            .opacity(gameManager.confettiAnimation)
            .offset(y: -20 * gameManager.confettiAnimation)
            .animation(.easeInOut(duration: 1.0), value: gameManager.confettiAnimation)
    }
}

