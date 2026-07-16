import Foundation

enum ReportPeriod: String, Sendable {
    case week
    case month
    case year
}

struct Report: Sendable {
    let period: ReportPeriod
    let activeDays: Int
    let restDays: Int
    let totalXP: Int
    let bestStreak: Int
    let activityBreakdown: [ActivityType: Int]
}
