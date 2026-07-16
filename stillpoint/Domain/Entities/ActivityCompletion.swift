import Foundation

struct ActivityCompletion: Identifiable, Sendable {
    let id: String
    let activityType: ActivityType
    let completedAt: Date
    let durationSeconds: Int
    let xpAwarded: Int
}
