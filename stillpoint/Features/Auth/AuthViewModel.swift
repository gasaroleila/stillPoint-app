import SwiftUI

enum AuthScreen: Equatable {
    case login
    case register
    case forgotPassword
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

    // Forgot password
    var resetEmail = ""
    var resetEmailSent = false

    private let auth: AuthRepositoryImpl

    init(auth: AuthRepositoryImpl) {
        self.auth = auth
    }

    func login() async {
        guard !loginEmail.isEmpty, !loginPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await auth.login(email: loginEmail, password: loginPassword)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func register() async {
        guard !registerUsername.isEmpty, !registerEmail.isEmpty, !registerPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        guard registerPassword == registerConfirmPassword else {
            errorMessage = "Passwords do not match."
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
}
