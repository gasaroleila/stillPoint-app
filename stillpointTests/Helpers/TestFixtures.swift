import Foundation
@testable import stillpoint

enum TestFixtures {
    static func userProfile(
        name: String = "Test User",
        xp: Int = 100,
        level: Int = 1,
        totalActivities: Int = 5
    ) -> UserProfile {
        UserProfile(id: UUID(), name: name, level: level, xp: xp, totalActivities: totalActivities, characterType: .person, growthStage: .newborn)
    }

    static func moodEntry(
        mood: MoodType = .happy,
        date: Date = .now
    ) -> MoodEntry {
        MoodEntry(id: UUID(), mood: mood, date: date)
    }

    static func streak(
        currentDays: Int = 3,
        longestDays: Int = 7,
        lastActivityDate: Date? = .now
    ) -> Streak {
        Streak(currentDays: currentDays, longestDays: longestDays, lastActivityDate: lastActivityDate)
    }

    static func badge(
        name: String = "First Steps",
        description: String = "Complete your first activity",
        isEarned: Bool = true,
        earnedDate: Date? = .now
    ) -> Badge {
        Badge(id: UUID(), name: name, description: description, isEarned: isEarned, earnedDate: earnedDate)
    }
}

enum TestError: Error, Equatable {
    case mock
    case networkFailure
}

actor CallCounter {
    private var count = 0

    @discardableResult
    func increment() -> Int {
        count += 1
        return count
    }

    var value: Int { count }
}
