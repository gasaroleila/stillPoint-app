import Foundation
import FirebaseFirestore

final class AuthRepositoryImpl: AuthRepository, @unchecked Sendable {
    private let authService = AuthService()
    private let db = Firestore.firestore()

    private(set) var isAuthenticated = false
    private(set) var currentUserId: String?

    func startListening(onChange: @escaping @Sendable (Bool) -> Void) {
        Task {
            await authService.startListening { [weak self] authenticated, userId in
                Task { @MainActor [weak self] in
                    self?.isAuthenticated = authenticated
                    self?.currentUserId = userId
                    onChange(authenticated)
                }
            }
        }
    }

    func register(username: String, email: String, password: String, dateOfBirth: Date) async throws {
        let uid = try await authService.register(email: email, password: password)

        let profileData: [String: Any] = [
            "username": username,
            "email": email,
            "dateOfBirth": Timestamp(date: dateOfBirth),
            "xp": 0,
            "growthStage": "newborn",
            "totalActivities": 0,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(uid).setData(profileData)

        let streakData: [String: Any] = [
            "currentDays": 0,
            "longestDays": 0
        ]
        try await db.collection("users").document(uid).collection("streak").document("current").setData(streakData)
    }

    func login(email: String, password: String) async throws -> AuthResult {
        try await authService.login(email: email, password: password)
        return .authenticated
    }

    func verifyMFA(code: String) async throws {
        // MFA implementation deferred to Phase 6
    }

    func setupMFA(phoneNumber: String) async throws {
        // MFA implementation deferred to Phase 6
    }

    func requestPasswordReset(email: String) async throws {
        try await authService.requestPasswordReset(email: email)
    }

    func logout() async throws {
        try await authService.logout()
    }
}
