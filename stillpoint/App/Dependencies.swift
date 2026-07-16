import Foundation

@MainActor
final class Dependencies: ObservableObject {
    let activities: any ActivityRepository
    let moods: any MoodRepository
    let user: any UserRepository

    init(
        activities: any ActivityRepository = ActivityRepositoryImpl(),
        moods: any MoodRepository = MoodRepositoryImpl(),
        user: any UserRepository = UserRepositoryImpl()
    ) {
        self.activities = activities
        self.moods = moods
        self.user = user
    }
}
