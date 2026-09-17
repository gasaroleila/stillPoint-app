import Foundation
import FirebaseFirestore

final class AuthRepositoryImpl: AuthRepository, @unchecked Sendable {
    private let authService: any AuthServiceProtocol
    private let db: Firestore

    private(set) var isAuthenticated = false
    private(set) var currentUserId: String?

    init(authService: any AuthServiceProtocol = AuthService(), db: Firestore = Firestore.firestore()) {
        self.authService = authService
        self.db = db
    }

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
        let requiresMFA = try await authService.login(email: email, password: password)
        return requiresMFA ? .requiresMFA : .authenticated
    }

    // MARK: - MFA Enrollment

    func setupMFA(phoneNumber: String) async throws -> String {
        try await authService.startMFAEnrollment(phoneNumber: phoneNumber)
    }

    func resendMFACode(phoneNumber: String) async throws -> String {
        try await authService.startMFAEnrollment(phoneNumber: phoneNumber)
    }

    func verifyMFA(code: String, verificationID: String) async throws {
        try await authService.completeMFAEnrollment(verificationID: verificationID, code: code)
    }

    // MARK: - MFA Login Challenge

    func sendMFALoginChallenge() async throws -> String {
        try await authService.sendMFALoginChallenge()
    }

    func completeMFALoginChallenge(code: String, verificationID: String) async throws {
        try await authService.completeMFALoginChallenge(verificationID: verificationID, code: code)
    }

    func requestPasswordReset(email: String) async throws {
        try await authService.requestPasswordReset(email: email)
    }

    func logout() async throws {
        try await authService.logout()
    }
}
