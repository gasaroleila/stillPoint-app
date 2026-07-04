import Foundation

struct UserProfile: Sendable {
    let id: UUID
    var name: String
    var level: Int
    var xp: Int
    var totalActivities: Int
}
