import Foundation
@testable import stillpoint

actor MockAuthService: AuthServiceProtocol {
    var isAuthenticated: Bool = false
    var currentUserId: String? = nil

    var registerResult: Result<String, Error> = .success("mock-uid-123")
    var loginError: Error? = nil
    var logoutError: Error? = nil
    var resetError: Error? = nil

    private(set) var registerCalls: [(email: String, password: String)] = []
    private(set) var loginCalls: [(email: String, password: String)] = []
    private(set) var logoutCallCount = 0
    private(set) var resetCalls: [String] = []
    private(set) var startListeningCallCount = 0
    private var onChangeCallback: (@Sendable (Bool, String?) -> Void)?

    func startListening(onChange: @escaping @Sendable (Bool, String?) -> Void) {
        startListeningCallCount += 1
        onChangeCallback = onChange
        onChange(isAuthenticated, currentUserId)
    }

    func simulateAuthStateChange(authenticated: Bool, userId: String?) {
        isAuthenticated = authenticated
        currentUserId = userId
        onChangeCallback?(authenticated, userId)
    }

    func stopListening() {}

    func register(email: String, password: String) async throws -> String {
        registerCalls.append((email, password))
        return try registerResult.get()
    }

    func login(email: String, password: String) async throws {
        loginCalls.append((email, password))
        if let error = loginError { throw error }
    }

    func logout() async throws {
        logoutCallCount += 1
        if let error = logoutError { throw error }
    }

    func requestPasswordReset(email: String) async throws {
        resetCalls.append(email)
        if let error = resetError { throw error }
    }

    // MARK: - Test configuration

    func setAuthState(authenticated: Bool, userId: String?) {
        isAuthenticated = authenticated
        currentUserId = userId
    }

    func setRegisterResult(_ result: Result<String, Error>) {
        registerResult = result
    }

    func setLoginError(_ error: Error?) {
        loginError = error
    }

    func setLogoutError(_ error: Error?) {
        logoutError = error
    }

    func setResetError(_ error: Error?) {
        resetError = error
    }
}
