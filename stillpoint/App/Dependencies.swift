import SwiftUI

@MainActor
final class Dependencies: ObservableObject {
    let auth: any AuthRepository
    let activities: any ActivityRepository
    let moods: any MoodRepository
    let user: any UserRepository

    @Published var isAuthenticated = false

    init(
        auth: any AuthRepository = AuthRepositoryImpl(),
        activities: any ActivityRepository = ActivityRepositoryImpl(),
        moods: any MoodRepository = MoodRepositoryImpl(),
        user: any UserRepository = UserRepositoryImpl()
    ) {
        self.auth = auth
        self.activities = activities
        self.moods = moods
        self.user = user

        auth.startListening { [weak self] authenticated in
            Task { @MainActor [weak self] in
                self?.isAuthenticated = authenticated
            }
        }
    }
}
