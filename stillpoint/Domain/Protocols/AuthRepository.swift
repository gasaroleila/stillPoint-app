import Foundation

enum AuthResult: Sendable {
    case authenticated
    case requiresMFA
}

protocol AuthRepository: Sendable {
    func register(username: String, email: String, password: String, dateOfBirth: Date) async throws
    func login(email: String, password: String) async throws -> AuthResult
    func setupMFA(phoneNumber: String) async throws -> String
    func resendMFACode(phoneNumber: String) async throws -> String
    func verifyMFA(code: String, verificationID: String) async throws
    func sendMFALoginChallenge() async throws -> String
    func completeMFALoginChallenge(code: String, verificationID: String) async throws
    func requestPasswordReset(email: String) async throws
    func logout() async throws
    func startListening(onChange: @escaping @Sendable (Bool) -> Void)
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }
}
