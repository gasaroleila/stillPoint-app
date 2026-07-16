import SwiftUI

struct ForgotPasswordView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                header

                if viewModel.resetEmailSent {
                    successMessage
                } else {
                    resetForm
                }

                backToLoginLink
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.top, 80)
            .padding(.bottom, 40)
        }
        .background(Color.spBackground)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Reset Password")
                .font(.spLargeTitle)
                .foregroundStyle(Color.spTextPrimary)
            Text("We'll send you a link to reset your password")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
    }

    private var resetForm: some View {
        VStack(spacing: 14) {
            AuthTextField(
                placeholder: "Email",
                text: $viewModel.resetEmail,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.spCaption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryCTA(title: viewModel.isLoading ? "Sending..." : "Send Reset Link") {
                Task { await viewModel.requestPasswordReset() }
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.6 : 1)
        }
    }

    private var successMessage: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.spPrimary)
            Text("Check your email")
                .font(.spHeading)
                .foregroundStyle(Color.spTextPrimary)
            Text("We've sent a password reset link to \(viewModel.resetEmail)")
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
    }

    private var backToLoginLink: some View {
        Button {
            viewModel.errorMessage = nil
            viewModel.resetEmailSent = false
            viewModel.screen = .login
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 12, weight: .bold))
                Text("Back to Sign In")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
            }
            .foregroundStyle(Color.spTextPrimary)
        }
        .padding(.top, 8)
    }
}
