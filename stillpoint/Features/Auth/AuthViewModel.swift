import SwiftUI

enum AuthScreen: Equatable {
    case login
    case forgotPassword
    case mfaChallenge
}

@MainActor
@Observable
final class AuthViewModel {
    var screen: AuthScreen = .login
    var isLoading = false
    var errorMessage: String?

    // Login fields
    var loginEmail = ""
    var loginPassword = ""

    // Register fields
    var registerUsername = ""
    var registerEmail = ""
    var registerPassword = ""
    var registerConfirmPassword = ""
    var registerDateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    var registerPhoneNumber = ""
    var agreedToPolicy = false
    var agreedToDisclaimer = false

    // Forgot password
    var resetEmail = ""
    var resetEmailSent = false

    // MFA
    var mfaDigits: [String] = Array(repeating: "", count: 6)
    var mfaVerificationID: String?
    var mfaIsEnrollment = false

    var mfaCode: String { mfaDigits.joined() }
    var isMFACodeComplete: Bool { mfaDigits.allSatisfy { !$0.isEmpty } }

    private let auth: any AuthRepository

    init(auth: any AuthRepository) {
        self.auth = auth
    }

    // MARK: - Login

    func login() async {
        guard !loginEmail.isEmpty, !loginPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        guard isValidEmail(loginEmail) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let result = try await auth.login(email: loginEmail, password: loginPassword)
            if result == .requiresMFA {
                let verificationID = try await auth.sendMFALoginChallenge()
                mfaVerificationID = verificationID
                mfaIsEnrollment = false
                resetMFADigits()
                screen = .mfaChallenge
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Register

    func register() async {
        guard !registerUsername.isEmpty, !registerEmail.isEmpty, !registerPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        guard isValidEmail(registerEmail) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard registerPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await auth.register(
                username: registerUsername,
                email: registerEmail,
                password: registerPassword,
                dateOfBirth: registerDateOfBirth
            )
        } catch {
            print("Registration error: \(error)")
            print("Localized: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("Domain: \(nsError.domain), Code: \(nsError.code)")
                print("UserInfo: \(nsError.userInfo)")
            }
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - MFA Enrollment (onboarding)

    func startMFAEnrollment() async {
        guard !registerPhoneNumber.isEmpty else {
            errorMessage = "Phone number is required for verification."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let verificationID = try await auth.setupMFA(phoneNumber: registerPhoneNumber)
            mfaVerificationID = verificationID
            mfaIsEnrollment = true
            resetMFADigits()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func verifyMFA() async {
        guard isMFACodeComplete, let verificationID = mfaVerificationID else { return }
        isLoading = true
        errorMessage = nil
        do {
            if mfaIsEnrollment {
                try await auth.verifyMFA(code: mfaCode, verificationID: verificationID)
            } else {
                try await auth.completeMFALoginChallenge(code: mfaCode, verificationID: verificationID)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    var mfaVerified: Bool {
        !isLoading && errorMessage == nil && mfaVerificationID != nil && isMFACodeComplete
    }

    func resendMFACode() async {
        isLoading = true
        errorMessage = nil
        do {
            if mfaIsEnrollment {
                let verificationID = try await auth.resendMFACode(phoneNumber: registerPhoneNumber)
                mfaVerificationID = verificationID
            } else {
                let verificationID = try await auth.sendMFALoginChallenge()
                mfaVerificationID = verificationID
            }
            resetMFADigits()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Password Reset

    func requestPasswordReset() async {
        guard !resetEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await auth.requestPasswordReset(email: resetEmail)
            resetEmailSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers

    private func isValidEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@")
        return parts.count == 2 && parts[1].contains(".")
    }

    private func resetMFADigits() {
        mfaDigits = Array(repeating: "", count: 6)
    }
}
