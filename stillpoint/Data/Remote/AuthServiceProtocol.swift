import Foundation

protocol AuthServiceProtocol: Sendable {
    var isAuthenticated: Bool { get async }
    var currentUserId: String? { get async }
    func startListening(onChange: @escaping @Sendable (Bool, String?) -> Void) async
    func stopListening() async
    func register(email: String, password: String) async throws -> String
    func login(email: String, password: String) async throws -> Bool
    func logout() async throws
    func requestPasswordReset(email: String) async throws

    // MFA enrollment (after registration)
    func startMFAEnrollment(phoneNumber: String) async throws -> String
    func completeMFAEnrollment(verificationID: String, code: String) async throws

    // MFA login challenge (when user with MFA logs in)
    func sendMFALoginChallenge() async throws -> String
    func completeMFALoginChallenge(verificationID: String, code: String) async throws
}
