import Foundation

struct Activity: Identifiable, Sendable {
    let id: UUID
    let type: ActivityType
    let title: String
    let description: String
    let durationMinutes: Int
    let xpReward: Int
}

enum ActivityType: String, CaseIterable, Sendable {
    case breathing
    case focus
    case coloring
    case journaling
}
