import Foundation

enum SuggestionStatus: String, Sendable {
    case pending
    case accepted
    case skipped
    case swapped
}

enum SuggestionAction: Sendable {
    case accept
    case skip
    case swap(newActivityType: ActivityType)
}

struct ActivitySuggestion: Identifiable, Sendable {
    let id: String
    let activityType: ActivityType
    let scheduledTime: Date?
    let status: SuggestionStatus
}
