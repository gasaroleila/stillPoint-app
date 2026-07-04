import SwiftUI

extension Color {
    static let spPrimary = Color(hex: 0xFFD60A)
    static let spPrimaryLight = Color(hex: 0xFFF8D6)
    static let spBackground = Color(hex: 0xFAFAF8)
    static let spBackgroundAlt = Color(hex: 0xF5F3EE)
    static let spTextPrimary = Color(hex: 0x0D0D0D)
    static let spTextSecondary = Color(hex: 0x7A7870)
    static let spBorder = Color(hex: 0xE8E6E0)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
