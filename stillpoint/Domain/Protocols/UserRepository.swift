import Foundation

protocol UserRepository: Sendable {
    func getProfile() async -> UserProfile
    func getStreak() async -> Streak
    func getBadges() async -> [Badge]
}
