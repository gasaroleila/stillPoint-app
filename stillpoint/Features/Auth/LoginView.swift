import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel

    @State private var showPassword = false

    private var isFormValid: Bool {
        !viewModel.loginEmail.isEmpty && !viewModel.loginPassword.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome back")
                        .font(.spPageTitle)
                        .foregroundStyle(Color.spTextPrimary)
                        .padding(.bottom, 4)

                    Text("Sign in to continue your journey.")
                        .font(.spSubtitle)
                        .foregroundStyle(Color.spTextSecondary)
                        .padding(.bottom, 24)

                    VStack(spacing: 12) {
                        fieldGroup(label: "EMAIL") {
                            TextField("you@example.com", text: $viewModel.loginEmail)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }

                        fieldGroup(label: "PASSWORD") {
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $viewModel.loginPassword)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Enter your password", text: $viewModel.loginPassword)
                                        .textContentType(.password)
                                }
                                Button { showPassword.toggle() } label: {
                                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.spTextSecondary)
                                }
                            }
                        }
                    }

                    errorBanner
                        .padding(.top, 8)

                    forgotPasswordLink
                        .padding(.top, 12)
                }
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.top, 80)
            }

            loginButton
                .padding(.horizontal, SP.Padding.screenHorizontal)
                .padding(.bottom, 36)
        }
        .background(Color.spBackground)
    }

    // MARK: - Field Group

    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("Nunito-Bold", size: 10.9))
                .foregroundStyle(Color.spTextSecondary)
                .tracking(0.76)

            content()
                .font(.custom("Nunito-Regular", size: 14.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.spBorder, lineWidth: 0.78)
                )
        }
    }

    // MARK: - Error Banner

    @ViewBuilder
    private var errorBanner: some View {
        if let error = viewModel.errorMessage {
            Text(error)
                .font(.spCaption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Forgot Password

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

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            Task { await viewModel.login() }
        } label: {
            Text(viewModel.isLoading ? "Signing in..." : "Sign In")
                .font(.custom("Nunito-Black", size: 16))
                .foregroundStyle(isFormValid ? Color.spTextPrimary : Color(hex: 0xB0ADA6))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isFormValid ? Color.spPrimary : Color(hex: 0xF0EDE8))
                .cornerRadius(20)
        }
        .disabled(!isFormValid || viewModel.isLoading)
    }
}
