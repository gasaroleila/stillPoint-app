import Foundation
import FirebaseAuth

private struct SendableResolver: @unchecked Sendable {
    let resolver: MultiFactorResolver
}

actor AuthService: AuthServiceProtocol {
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var _isAuthenticated = false
    private var _currentUserId: String?
    private var mfaResolver: SendableResolver?

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

    func login(email: String, password: String) async throws -> Bool {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return false
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.secondFactorRequired.rawValue,
               let resolver = nsError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as? MultiFactorResolver {
                mfaResolver = SendableResolver(resolver: resolver)
                return true
            }
            throw error
        }
    }

    func logout() throws {
        try Auth.auth().signOut()
    }

    func requestPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - MFA Enrollment

    func startMFAEnrollment(phoneNumber: String) async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw AuthMFAError.notSignedIn
        }
        let session = try await user.multiFactor.session()
        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
            phoneNumber,
            uiDelegate: nil,
            multiFactorSession: session
        )
        return verificationID
    }

    func completeMFAEnrollment(verificationID: String, code: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthMFAError.notSignedIn
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
        try await user.multiFactor.enroll(with: assertion, displayName: "Phone")
    }

    // MARK: - MFA Login Challenge

    func sendMFALoginChallenge() async throws -> String {
        guard let wrapped = mfaResolver,
              let hint = wrapped.resolver.hints.first as? PhoneMultiFactorInfo else {
            throw AuthMFAError.noMFAResolver
        }
        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
            with: hint,
            uiDelegate: nil,
            multiFactorSession: wrapped.resolver.session
        )
        return verificationID
    }

    func completeMFALoginChallenge(verificationID: String, code: String) async throws {
        guard let wrapped = mfaResolver else {
            throw AuthMFAError.noMFAResolver
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
        try await wrapped.resolver.resolveSignIn(with: assertion)
        mfaResolver = nil
    }
}

enum AuthMFAError: LocalizedError {
    case notSignedIn
    case noMFAResolver

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "You must be signed in to set up phone verification."
        case .noMFAResolver: return "No pending MFA challenge. Please try logging in again."
        }
    }
}
