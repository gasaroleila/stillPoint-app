import Foundation

@MainActor
@Observable
final class HomeViewModel {
    var userName: String = ""
    var streakDays: Int = 0
    var totalXP: Int = 0
    var characterType: CharacterType = .person
    var selectedMood: MoodType? = nil
    var moodConfirmed = false
    var completedActivities: Set<ActivityType> = []
    var suggestions: [ActivitySuggestion] = []

    // XP values matching backend (firebase/functions/src/xp.ts)
    static let xpPerActivity: [ActivityType: Int] = [
        .breathing: 20, .focus: 50, .coloring: 30, .journaling: 25
    ]

    var earnedXP: Int {
        completedActivities.reduce(0) { $0 + (Self.xpPerActivity[$1] ?? 0) }
    }

    /// Returns 3 suggested activities from the backend, or all 4 as fallback
    var displayedActivities: [HomeActivity] {
        let types: [ActivityType]
        if suggestions.isEmpty {
            types = ActivityType.allCases
        } else {
            types = suggestions.map(\.activityType)
        }
        return types.map { type in
            Self.activityDisplay[type]!
        }
    }

    /// Max daily XP based on displayed activities
    var maxDailyXP: Int {
        displayedActivities.reduce(0) { $0 + (Self.xpPerActivity[$1.type] ?? 0) }
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
            characterType = profile.characterType

            let streak = try await user.getStreak()
            streakDays = streak.currentDays

            await loadTodaySuggestions()
            await loadTodayMood()
            await loadTodayCompletions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadTodaySuggestions() async {
        do {
            suggestions = try await activities.getTodaySuggestions()
        } catch {
            // Non-critical — falls back to showing all 4 activities
        }
    }

    private func loadTodayMood() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        do {
            let todayMoods = try await moods.getMoodHistory(from: startOfDay, to: endOfDay)
            print("[Mood] Loaded \(todayMoods.count) moods for today")
            if let latest = todayMoods.first {
                selectedMood = latest.mood
                moodConfirmed = true
            }
        } catch {
            print("[Mood] Load error: \(error)")
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
        guard let mood = selectedMood, !moodConfirmed else {
            print("[Mood] Guard failed — selectedMood: \(String(describing: selectedMood)), moodConfirmed: \(moodConfirmed)")
            return
        }
        do {
            print("[Mood] Logging mood: \(mood.rawValue)")
            try await moods.logMood(mood)
            print("[Mood] Success")
            moodConfirmed = true
        } catch {
            print("[Mood] Error: \(error)")
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

    // MARK: - Activity display metadata

    private static let activityDisplay: [ActivityType: HomeActivity] = [
        .breathing: HomeActivity(
            type: .breathing,
            iconAsset: "breathing",
            title: "Box Breathing",
            description: "Calm your nervous system with a guided breathing pattern",
            durationText: "~2 min",
            xpText: "+20 XP"
        ),
        .focus: HomeActivity(
            type: .focus,
            iconAsset: "focus",
            title: "Deep Focus",
            description: "20 minutes of undivided attention to what matters most",
            durationText: "20 min",
            xpText: "+50 XP"
        ),
        .coloring: HomeActivity(
            type: .coloring,
            iconAsset: "coloring",
            title: "Coloring",
            description: "Color a cute mushroom garden — relax and be creative",
            durationText: "5 min",
            xpText: "+30 XP"
        ),
        .journaling: HomeActivity(
            type: .journaling,
            iconAsset: "journal",
            title: "Journal",
            description: "Reflect on your day and clear your mind with free writing",
            durationText: "~10 min",
            xpText: "+25 XP"
        ),
    ]
}

struct HomeActivity {
    let type: ActivityType
    let iconAsset: String
    let title: String
    let description: String
    let durationText: String
    let xpText: String
}
