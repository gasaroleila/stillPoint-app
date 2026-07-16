import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                header
                fields
                errorBanner
                registerButton
                loginLink
            }
            .padding(.horizontal, SP.Padding.screenHorizontal)
            .padding(.top, 80)
            .padding(.bottom, 40)
        }
        .background(Color.spBackground)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Create Account")
                .font(.spLargeTitle)
                .foregroundStyle(Color.spTextPrimary)
            Text("Start your mindfulness journey")
                .font(.spSubtitle)
                .foregroundStyle(Color.spTextSecondary)
        }
        .padding(.bottom, 16)
    }

    private var fields: some View {
        VStack(spacing: 14) {
            AuthTextField(
                placeholder: "Username",
                text: $viewModel.registerUsername,
                textContentType: .username,
                autocapitalization: .never
            )
            AuthTextField(
                placeholder: "Email",
                text: $viewModel.registerEmail,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )
            AuthTextField(
                placeholder: "Password",
                text: $viewModel.registerPassword,
                isSecure: true,
                textContentType: .newPassword
            )
            AuthTextField(
                placeholder: "Confirm Password",
                text: $viewModel.registerConfirmPassword,
                isSecure: true,
                textContentType: .newPassword
            )
            DatePicker(
                "Date of Birth",
                selection: $viewModel.registerDateOfBirth,
                in: ...Date.now,
                displayedComponents: .date
            )
            .font(.spBody)
            .foregroundStyle(Color.spTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(SP.Radius.icon)
            .overlay(
                RoundedRectangle(cornerRadius: SP.Radius.icon)
                    .stroke(Color.spBorder, lineWidth: 1)
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

    private var registerButton: some View {
        PrimaryCTA(title: viewModel.isLoading ? "Creating account..." : "Create Account") {
            Task { await viewModel.register() }
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1)
    }

    private var loginLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(.spBody)
                .foregroundStyle(Color.spTextSecondary)
            Button {
                viewModel.errorMessage = nil
                viewModel.screen = .login
            } label: {
                Text("Sign In")
                    .font(.custom("Nunito-ExtraBold", size: 12.5))
                    .foregroundStyle(Color.spTextPrimary)
            }
        }
        .padding(.top, 8)
    }
}
