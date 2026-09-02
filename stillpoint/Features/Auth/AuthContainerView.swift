import SwiftUI

struct AuthContainerView: View {
    @State var viewModel: AuthViewModel

    var body: some View {
        Group {
            switch viewModel.screen {
            case .login:
                LoginView(viewModel: viewModel)
            case .forgotPassword:
                ForgotPasswordView(viewModel: viewModel)
            case .mfaChallenge:
                MFAView(
                    viewModel: viewModel,
                    onVerify: {
                        // MFA login challenge completed — auth state listener
                        // will pick up the sign-in automatically
                    },
                    onBack: {
                        viewModel.errorMessage = nil
                        viewModel.screen = .login
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.screen)
    }
}
