import Foundation
@testable import stillpoint

final class MockAuthRepository: AuthRepository, @unchecked Sendable {
    var isAuthenticated: Bool = false
    var currentUserId: String? = nil

    var loginResult: AuthResult = .authenticated
    var loginError: Error? = nil
    var registerError: Error? = nil
    var logoutError: Error? = nil
    var resetError: Error? = nil

    private(set) var registerCalls: [(username: String, email: String, password: String)] = []
    private(set) var loginCalls: [(email: String, password: String)] = []
    private(set) var logoutCallCount = 0
    private(set) var resetCalls: [String] = []

    func startListening(onChange: @escaping @Sendable (Bool) -> Void) {
        onChange(isAuthenticated)
    }

    func register(username: String, email: String, password: String, dateOfBirth: Date) async throws {
        registerCalls.append((username, email, password))
        if let error = registerError { throw error }
    }

    func login(email: String, password: String) async throws -> AuthResult {
        loginCalls.append((email, password))
        if let error = loginError { throw error }
        return loginResult
    }

    func verifyMFA(code: String) async throws {}

    func setupMFA(phoneNumber: String) async throws {}

    func requestPasswordReset(email: String) async throws {
        resetCalls.append(email)
        if let error = resetError { throw error }
    }

    func logout() async throws {
        logoutCallCount += 1
        if let error = logoutError { throw error }
    }
}
