import Foundation

enum GrowthStage: String, Sendable {
    case newborn
    case sprouting
    case young
    case mature

    var label: String {
        rawValue.capitalized
    }
}

struct GamificationStatus: Sendable {
    let xp: Int
    let growthStage: GrowthStage
    let streakDays: Int
    let longestStreak: Int
}
