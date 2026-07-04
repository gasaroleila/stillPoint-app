import Foundation

struct Streak: Sendable {
    var currentDays: Int
    var longestDays: Int
    var lastActivityDate: Date?
}
