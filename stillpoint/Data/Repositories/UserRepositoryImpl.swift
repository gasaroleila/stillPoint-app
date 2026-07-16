import Foundation

struct UserRepositoryImpl: UserRepository {
    func getProfile() async throws -> UserProfile {
        UserProfile(id: UUID(), name: "User", level: 1, xp: 0, totalActivities: 0)
    }

    func updateProfile(name: String) async throws {
        // Stub — will write to Firestore in Phase 3
    }

    func getStreak() async throws -> Streak {
        Streak(currentDays: 0, longestDays: 0, lastActivityDate: nil)
    }

    func getBadges() async throws -> [Badge] {
        []
    }

    func getGamificationStatus() async throws -> GamificationStatus {
        GamificationStatus(xp: 0, growthStage: .newborn, streakDays: 0, longestStreak: 0)
    }

    func getReport(period: ReportPeriod) async throws -> Report {
        Report(period: period, activeDays: 0, restDays: 0, totalXP: 0, bestStreak: 0, activityBreakdown: [:])
    }
}
