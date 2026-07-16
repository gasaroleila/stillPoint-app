import Foundation

enum AuthResult: Sendable {
    case authenticated
    case requiresMFA
}

protocol AuthRepository: Sendable {
    func register(username: String, email: String, password: String, dateOfBirth: Date) async throws
    func login(email: String, password: String) async throws -> AuthResult
    func verifyMFA(code: String) async throws
    func setupMFA(phoneNumber: String) async throws
    func requestPasswordReset(email: String) async throws
    func logout() async throws
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }
}
