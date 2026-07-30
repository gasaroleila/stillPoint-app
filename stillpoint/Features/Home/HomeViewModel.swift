import Foundation

@MainActor
@Observable
final class HomeViewModel {
    var userName: String = ""
    var streakDays: Int = 0
    var totalXP: Int = 0
    var selectedMood: MoodType? = nil
    var moodConfirmed = false
    var earnedXP: Int = 0
    var completedActivities: Set<ActivityType> = []
    var errorMessage: String?

    private let moods: any MoodRepository
    private let activities: any ActivityRepository
    private let user: any UserRepository

    init(moods: any MoodRepository, activities: any ActivityRepository, user: any UserRepository) {
        self.moods = moods
        self.activities = activities
        self.user = user
    }

    func loadProfile() async {
        do {
            let profile = try await user.getProfile()
            userName = profile.name
            totalXP = profile.xp

            let streak = try await user.getStreak()
            streakDays = streak.currentDays

            await loadTodayMood()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadTodayMood() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        do {
            let todayMoods = try await moods.getMoodHistory(from: startOfDay, to: endOfDay)
            if let latest = todayMoods.first {
                selectedMood = latest.mood
                moodConfirmed = true
            }
        } catch {
            // Non-critical — just means we can't restore today's mood
        }
    }

    func confirmMood() async {
        guard let mood = selectedMood else { return }
        do {
            try await moods.logMood(mood)
            moodConfirmed = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logActivityCompletion(type: ActivityType, durationSeconds: Int, xp: Int) async {
        do {
            try await activities.logCompletion(activityType: type, duration: durationSeconds)
            earnedXP += xp
            completedActivities.insert(type)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
