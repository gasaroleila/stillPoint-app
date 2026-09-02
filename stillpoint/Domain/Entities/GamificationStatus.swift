import Foundation

enum GrowthStage: String, Sendable {
    case newborn
    case sprouting
    case young
    case mature

    var label: String {
        rawValue.capitalized
    }

    var xpThreshold: Int {
        switch self {
        case .newborn: return 0
        case .sprouting: return 201
        case .young: return 1501
        case .mature: return 8001
        }
    }

    var nextStageThreshold: Int? {
        switch self {
        case .newborn: return 201
        case .sprouting: return 1501
        case .young: return 8001
        case .mature: return nil
        }
    }

    var next: GrowthStage? {
        switch self {
        case .newborn: return .sprouting
        case .sprouting: return .young
        case .young: return .mature
        case .mature: return nil
        }
    }

    /// Returns 0.0–1.0 progress toward the next stage. 1.0 if mature.
    func progress(xp: Int) -> Double {
        guard let nextThreshold = nextStageThreshold else { return 1.0 }
        let rangeSize = nextThreshold - xpThreshold
        let current = xp - xpThreshold
        return min(max(Double(current) / Double(rangeSize), 0), 1)
    }
}

struct GamificationStatus: Sendable {
    let xp: Int
    let growthStage: GrowthStage
    let streakDays: Int
    let longestStreak: Int
}
