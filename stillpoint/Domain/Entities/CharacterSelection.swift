import Foundation

enum CharacterType: String, CaseIterable, Sendable {
    case person
    case plant
    case bird
    case cat
}

struct CharacterSelection: Sendable {
    let type: CharacterType
    let variant: String
}
