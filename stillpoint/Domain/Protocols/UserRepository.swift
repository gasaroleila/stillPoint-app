import Foundation

protocol UserRepository: Sendable {
    func getProfile() async throws -> UserProfile
    func updateProfile(name: String) async throws
    func saveCharacterSelection(type: CharacterType, skinTone: Int, hat: String, accessory: String) async throws
    func getStreak() async throws -> Streak
    func getBadges() async throws -> [Badge]
    func getGamificationStatus() async throws -> GamificationStatus
    func getReport(period: ReportPeriod) async throws -> Report
}
