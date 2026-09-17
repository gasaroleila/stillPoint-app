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
        activities: (any ActivityRepository)? = nil,
        moods: (any MoodRepository)? = nil,
        user: (any UserRepository)? = nil
    ) {
        self.auth = auth

        let firestoreService = FirestoreService {
            auth.currentUserId
        }

        self.activities = activities ?? ActivityRepositoryImpl(firestore: firestoreService)
        self.moods = moods ?? MoodRepositoryImpl(firestore: firestoreService)
        self.user = user ?? UserRepositoryImpl(firestore: firestoreService)

        auth.startListening { [weak self] authenticated in
            Task { @MainActor [weak self] in
                self?.isAuthenticated = authenticated
            }
        }
    }
}
