import Foundation

@MainActor
@Observable
final class HomeViewModel {
    var userName: String = ""
    var streakDays: Int = 0
    var totalXP: Int = 0
    var selectedMood: MoodType? = nil
    var moodConfirmed = false
    var completedActivities: Set<ActivityType> = []

    private static let xpPerActivity: [ActivityType: Int] = [
        .breathing: 30, .focus: 60, .coloring: 25, .journaling: 80
    ]

    var earnedXP: Int {
        completedActivities.reduce(0) { $0 + (Self.xpPerActivity[$1] ?? 0) }
    }
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
            await loadTodayCompletions()
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

    private func loadTodayCompletions() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        do {
            let completions = try await activities.getCompletions(from: startOfDay, to: endOfDay)
            completedActivities = Set(completions.map(\.activityType))
        } catch {
            // Non-critical
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

    func logActivityCompletion(type: ActivityType, durationSeconds: Int) async {
        do {
            try await activities.logCompletion(activityType: type, duration: durationSeconds)
            completedActivities.insert(type)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
