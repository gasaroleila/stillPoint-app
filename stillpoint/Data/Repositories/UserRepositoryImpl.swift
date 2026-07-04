import Foundation

struct UserRepositoryImpl: UserRepository {
    func getProfile() async -> UserProfile {
        UserProfile(id: UUID(), name: "User", level: 1, xp: 0, totalActivities: 0)
    }

    func getStreak() async -> Streak {
        Streak(currentDays: 0, longestDays: 0, lastActivityDate: nil)
    }

    func getBadges() async -> [Badge] {
        []
    }
}
