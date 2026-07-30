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
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.screen)
    }
}
