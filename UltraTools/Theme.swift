import SwiftUI

/// Общий дизайн UltraTools: палитра, градиенты, карточки.
enum Theme {
    static let accent = Color(red: 0.35, green: 0.72, blue: 1.0)
    static let green = Color(red: 0.20, green: 0.85, blue: 0.60)
    static let red = Color(red: 0.95, green: 0.30, blue: 0.34)
    static let orange = Color(red: 1.0, green: 0.62, blue: 0.26)

    static let card = Color.white.opacity(0.06)
    static let cardStroke = Color.white.opacity(0.10)

    static var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.08, blue: 0.13),
                Color(red: 0.02, green: 0.02, blue: 0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Палитра островка (0 — классический чёрный, как у настоящего Dynamic Island).
    static let islandColors: [Color] = [
        Color.black,
        Color(red: 0.95, green: 0.27, blue: 0.31),
        Color(red: 0.20, green: 0.85, blue: 0.60),
        Color(red: 0.35, green: 0.72, blue: 1.0),
        Color(red: 0.62, green: 0.45, blue: 1.0),
        Color(red: 1.0, green: 0.62, blue: 0.26),
        Color(red: 0.98, green: 0.80, blue: 0.30),
        Color(red: 0.99, green: 0.48, blue: 0.79)
    ]

    static func islandColor(_ index: Int) -> Color {
        islandColors[((index % islandColors.count) + islandColors.count) % islandColors.count]
    }

    static func islandGradient(_ index: Int) -> LinearGradient {
        LinearGradient(
            colors: [islandColor(index), islandColor((index + 2) % islandColors.count)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Стеклянная карточка в стиле UltraTools.
    func utCard() -> some View {
        self
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.cardStroke, lineWidth: 1)
            }
    }
}
