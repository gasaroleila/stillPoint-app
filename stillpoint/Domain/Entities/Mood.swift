import Foundation

enum MoodType: String, CaseIterable, Sendable {
    case stressed
    case sad
    case neutral
    case happy
    case overwhelmed

    var label: String {
        rawValue.capitalized
    }

    var assetName: String { rawValue }
}

struct MoodEntry: Identifiable, Sendable {
    let id: UUID
    let mood: MoodType
    let date: Date
}
