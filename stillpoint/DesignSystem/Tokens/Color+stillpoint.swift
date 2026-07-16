import SwiftUI

extension Color {
    static let spPrimary = Color(hex: 0xFFD60A)
    static let spPrimaryLight = Color(hex: 0xFFF8D6)
    static let spBackground = Color(hex: 0xFAFAF8)
    static let spBackgroundAlt = Color(hex: 0xFFFDF0)
    static let spTextPrimary = Color(hex: 0x0D0D0D)
    static let spTextSecondary = Color(hex: 0x7A7870)
    static let spBorder = Color(hex: 0xE8E6E0)

    static let spChartMedium = Color(hex: 0xFFE57A)
    static let spChartLight = Color(hex: 0xFFF3B0)
    static let spChartEmpty = Color(hex: 0xEDE9DF)

    static let spActivityJournal = Color(hex: 0xFFF3E0)
    static let spActivityBreathing = Color(hex: 0xEAF7FD)
    static let spActivityFocus = Color(hex: 0xF3EEFF)
    static let spActivityColoring = Color(hex: 0xFFF0F5)

    static let spOverlay = Color.black.opacity(0.12)
    static let spLockedBadgeBg = Color(hex: 0xF2F0EB)
    static let spStatusText = Color(hex: 0xE6A800)
    static let spMoodLabelInactive = Color.white.opacity(0.5)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
