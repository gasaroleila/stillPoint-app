import Foundation
import FirebaseAuth

actor AuthService: AuthServiceProtocol {
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var _isAuthenticated = false
    private var _currentUserId: String?

    var isAuthenticated: Bool { _isAuthenticated }
    var currentUserId: String? { _currentUserId }

    func startListening(onChange: @escaping @Sendable (Bool, String?) -> Void) {
        let handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            let authenticated = user != nil
            let userId = user?.uid
            Task { [weak self] in
                await self?.updateState(authenticated: authenticated, userId: userId)
                onChange(authenticated, userId)
            }
        }
        authStateHandle = handle
    }

    func stopListening() {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateHandle = nil
        }
    }

    private func updateState(authenticated: Bool, userId: String?) {
        _isAuthenticated = authenticated
        _currentUserId = userId
    }

    func register(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    func requestPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
