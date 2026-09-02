import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    var userName: String = ""
    var xp: Int = 0
    var level: Int = 1
    var streakDays: Int = 0
    var totalActivities: Int = 0
    var characterType: CharacterType = .person
    var growthStage: GrowthStage = .newborn
    var earnedBadgeIds: Set<String> = []
    var errorMessage: String?

    private let user: any UserRepository

    init(user: any UserRepository) {
        self.user = user
    }

    var levelDisplay: String {
        "\(growthStage.label) \u{00B7} \(xp) XP"
    }

    func load() async {
        do {
            let profile = try await user.getProfile()
            userName = profile.name
            xp = profile.xp
            level = profile.level
            totalActivities = profile.totalActivities
            characterType = profile.characterType
            growthStage = profile.growthStage

            let streak = try await user.getStreak()
            streakDays = streak.currentDays

            let badges = try await user.getBadges()
            earnedBadgeIds = Set(badges.filter(\.isEarned).map(\.name))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
