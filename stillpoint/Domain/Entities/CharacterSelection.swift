import Foundation

enum CharacterType: String, CaseIterable, Sendable {
    case person
    case plant
    case bird
    case cat

    var iconName: String {
        switch self {
        case .person: return "figure.stand"
        case .plant: return "leaf.fill"
        case .bird: return "bird.fill"
        case .cat: return "cat.fill"
        }
    }
}

struct CharacterSelection: Sendable {
    let type: CharacterType
    let variant: String
}
