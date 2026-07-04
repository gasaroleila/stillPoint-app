import Foundation

struct Badge: Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    var isEarned: Bool
    var earnedDate: Date?
}
