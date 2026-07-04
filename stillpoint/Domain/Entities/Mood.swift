import Foundation

enum MoodType: String, CaseIterable, Sendable {
    case happy
    case calm
    case neutral
    case sad
    case stressed
}

struct MoodEntry: Identifiable, Sendable {
    let id: UUID
    let mood: MoodType
    let date: Date
}
