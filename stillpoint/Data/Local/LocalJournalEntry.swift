import Foundation
import SwiftData

@Model
final class LocalJournalEntry {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), content: String = "", createdAt: Date = .now) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}
