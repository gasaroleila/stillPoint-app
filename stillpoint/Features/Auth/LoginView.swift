import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                header
                fields
                errorBanner
                loginButton
                forgotPasswordLink
                registerLink
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.top, 80)
            .padding(.bottom, 40)
        }
        .background(Color.spBackground)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Welcome Back")
                .font(.spLargeTitle)
                .foregroundStyle(Color.spTextPrimary)
            Text("Sign in to continue your journey")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
        }
        .padding(.bottom, 16)
    }

    private var fields: some View {
        VStack(spacing: 14) {
            AuthTextField(
                placeholder: "Email",
                text: $viewModel.loginEmail,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )
            AuthTextField(
                placeholder: "Password",
                text: $viewModel.loginPassword,
                isSecure: true,
                textContentType: .password
            )
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let error = viewModel.errorMessage {
            Text(error)
                .font(.spCaption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var loginButton: some View {
        PrimaryCTA(title: viewModel.isLoading ? "Signing in..." : "Sign In") {
            Task { await viewModel.login() }
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1)
    }

    private var forgotPasswordLink: some View {
        Button {
            viewModel.errorMessage = nil
            viewModel.screen = .forgotPassword
        } label: {
            Text("Forgot password?")
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
        }
    }

    private var registerLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
            Button {
                viewModel.errorMessage = nil
                viewModel.screen = .register
            } label: {
                Text("Sign Up")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextPrimary)
            }
        }
        .padding(.top, 8)
    }
}
